CREATE OR REPLACE FUNCTION tasker.can_do (
    a_user in text default null,
    a_action in text default null,
    a_object_type in text default null,
    a_id in integer default null,
    a_parent_object_type in text default null,
    a_parent_id in integer default null )
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function can_do determines if a user has permission to perform the specified action on the specified object (optionally for the specified ID)

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_user                         | in     | text       | The user to check permissions for                  |
| a_action                       | in     | text       | The action to perform                              |
| a_object_type                  | in     | text       | The (name of) the type of object to perform the action on |
| a_id                           | in     | integer    | The ID of the object to check permissions for      |
| a_parent_object_type           | in     | text       | The (name of) the type of object that is the parent of the object to check permissions for (this is for inserts) |
| a_parent_id                    | in     | integer    | The ID of the parent object to check permissions for (this is for inserts) |

NOTES

 * To help prevent privilege escalation attacks, both the acting user and the connected user
 need to have sufficient permissions to perform the action

*/
DECLARE

    r record ;

    l_action text ;
    l_can_do boolean ;
    l_connected_can_validate boolean := false ;
    l_user_activity_role text ;

    l_acting_user tasker.ut_user_stats ;
    l_session_user tasker.ut_user_stats ;
    l_object tasker.ut_object_stats ;

BEGIN

--RAISE NOTICE E'\n\ncan_do ( %, %, %, %, %, % )', a_user, a_action, a_object_type, a_id, a_parent_object_type, a_parent_id ;

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Initial sanity checking of the parameters

    -- Ensure that an object type was specified and that it is valid
    l_object := tasker.get_object_stats (
        a_object_type => a_object_type,
        a_id => a_id,
        a_parent_object_type => a_parent_object_type,
        a_parent_id => a_parent_id ) ;

--RAISE NOTICE E'l_object ( % )', l_object ;

    IF l_object.object_type IS NULL THEN
        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that the action specified is valid for the object type.
/*
    FOR r IN (
        WITH actual AS (
            SELECT lower ( soa.name ) AS action
                FROM tasker_data.st_object_action soa
                WHERE soa.is_enabled
                    AND lower ( soa.name ) = lower ( trim ( a_action ) )
        )
        SELECT actual.action
            FROM actual
            WHERE EXISTS (
                    SELECT 1
                        FROM tasker.sv_object_permission sop
                        WHERE lower ( sop.action ) = actual.action
                            AND sop.object_type_id = l_object.object_type_id )
        ) LOOP

        l_action := r.action ;

    END LOOP ;
*/


    FOR r IN (
        SELECT lower ( soa.name ) AS action
            FROM tasker_data.st_object_action soa
            WHERE soa.is_enabled
                AND lower ( soa.name ) = lower ( trim ( a_action ) )
        ) LOOP

        l_action := r.action ;

    END LOOP ;

--RAISE NOTICE E'l_action ( % )', l_action ;

    IF l_action IS NULL THEN
        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that, if acting on an existing object, an object ID was provided
    IF l_object.object_type <> 'reference' AND l_object.object_id IS NULL THEN

        IF l_action IN ( 'update', 'update status', 'delete' ) THEN
            RETURN false ;
        END IF ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that the activity, if there is one, is open for non-select actions
    -- on objects under the activity
    IF l_object.activity_id IS NOT NULL
        AND l_object.object_type <> 'activity'
        AND l_action <> 'select'
        AND l_object.status_category <> 'Open' THEN

        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that there is an acting user and that they are enabled
    l_acting_user := tasker.get_user_stats ( a_user => a_user ) ;
    IF l_action <> 'select' THEN
        IF NOT ( l_acting_user.user_id IS NOT NULL AND l_acting_user.is_enabled ) THEN
            RETURN false ;
        END IF ;
    END IF ;

    -- Ensure that there is a connected user, they are enabled, and that they are not, somehow, a "public" user
    l_session_user := tasker.get_user_stats ( a_user => session_user::text ) ;
    IF NOT ( l_session_user.user_id IS NOT NULL AND l_session_user.is_enabled ) THEN
        RETURN false ;
    ELSIF l_session_user.is_public THEN
        RETURN false ;
    END IF ;

    -- Determine if the connected user is sufficient for validating actions for
    -- the acting user-- which means that either the acting user is the connected
    -- (database session) user or that the connected user is an administrator
    l_connected_can_validate := l_session_user.is_admin OR l_acting_user.user_id = l_session_user.user_id ;

    IF NOT l_connected_can_validate THEN
        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Since most actions will probably be SELECT, and since SELECT is the
    -- simplest case we will deal with it first
    IF l_action = 'select' THEN

        l_can_do := false ;

        IF l_object.object_type = 'reference' THEN
           l_can_do := NOT l_acting_user.is_public ;

        ELSIF l_object.object_type = 'user' THEN
            l_can_do :=  l_acting_user.is_admin ;

        ELSIF l_object.object_type = 'profile' THEN
            l_can_do :=  l_acting_user.user_id = a_id ;

        ELSIF l_object.object_type = 'journal' THEN

            -- Users may select from their journal entries
            IF l_object.object_owner_id = l_acting_user.user_id THEN

                l_can_do := true ;

            ELSE

                -- Supervisors/managers may select from the journal entries of their reports
                FOR r IN (
                    SELECT 1
                        FROM tasker.dv_user_reporting_chain
                        WHERE user_id = l_object.object_owner_id
                            AND l_acting_user.user_id = ANY ( reporting_chain )
                    ) LOOP

                    l_can_do := true ;
                    EXIT ;

                END LOOP ;

            END IF ;

        ELSE
            --------------------------------------------------------------------
            -- Assert: the only thing left to check are comments and the various
            -- task type objects
            --
            -- data for public activities may be selected
            -- data for protected activities may be selected by known users
            -- data for private activities may only be selected by activity members
            IF l_object.activity_visibility = 'Public' THEN
                l_can_do := true ;

            ELSEIF l_object.activity_visibility = 'Protected' THEN
                l_can_do := NOT l_acting_user.is_public ;

            ELSIF l_object.activity_visibility = 'Private' THEN

                IF l_acting_user.is_enabled AND l_acting_user.is_admin THEN
                    l_can_do := true ;

                ELSE

                    FOR r IN (
                        SELECT user_id
                            FROM tasker_data.dt_activity_member
                            WHERE activity_id = l_object.activity_id
                                AND user_id = l_acting_user.user_id ) LOOP

                        l_can_do := true ;

                    END LOOP ;

                END IF ;

            END IF ;

        END IF ;

        RETURN l_can_do ;

    END IF ;

    ----------------------------------------------------------------------------
    -- With SELECT dealt with, public users are done
    -- TODO: will need something for dealing with new account requests at some point
    IF l_acting_user.is_public THEN
        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    IF l_object.object_type IN ( 'reference', 'user' ) THEN

        -- select is already dealt with and only administrators can do otherwise
        RETURN l_acting_user.is_admin ;

    END IF ;

    IF l_object.object_type = 'profile' THEN
        RETURN l_acting_user.user_id = a_id AND l_action IN ( 'insert', 'update' ) ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Assert: the only things left to check are related to activities

    -- Sanity check
    IF l_object.activity_id IS NULL THEN

        -- Ensure that, for non activity objects, there is an activity to insert into.
        -- Ensure that, for non insert actions, there is an activity
        IF ( l_action = 'insert' AND l_object.object_type <> 'activity' )
            OR ( l_action <> 'insert' ) THEN

            RETURN false ;

        END IF ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Get the activity role for the user
    FOR r IN (
        SELECT role
            FROM tasker.dv_activity_member
            WHERE activity_id = l_object.activity_id
                AND user_id = l_acting_user.user_id ) LOOP

        l_user_activity_role := r.role ;

    END LOOP ;

    ----------------------------------------------------------------------------
    IF l_object.object_type = 'journal' THEN

         -- select is already dealt with
        IF l_action IN ( 'update', 'delete' ) THEN

            RETURN l_object.object_owner_id = l_acting_user.user_id ;

        ELSIF l_action = 'insert' THEN

            IF l_object.status_category = 'Closed' THEN
                RETURN false ;
            END IF ;

            -- must be assigned to the parent object
            -- OR be owner of the parent object
            -- OR be a member of the activity with a role >= Member
            IF l_acting_user.user_id IN ( l_object.parent_owner_id, l_object.parent_assignee_id ) THEN

                RETURN true ;

            END IF ;

            RETURN l_user_activity_role IS NOT NULL AND l_user_activity_role NOT IN ( 'Observer', 'Reporter' ) ;

        END IF ;

        RETURN false ;

    END IF ;

    IF l_object.object_type = 'comment' THEN

        -- updates and deletes by the comment owner
        -- deletes also by the system administrator
        IF l_action IN ( 'update', 'delete' ) THEN

            FOR r IN (
                SELECT id
                    FROM tasker_data.dt_task_comment
                    WHERE owner_id = l_acting_user.user_id ) LOOP

                RETURN true ;

            END LOOP ;

            RETURN l_acting_user.is_admin AND l_action = 'delete' ;

        ELSIF l_action = 'insert' THEN

            IF l_object.status_category = 'Closed' THEN
                RETURN false ;
            END IF ;

            -- inserts only by activity members
            RETURN l_user_activity_role IS NOT NULL AND l_user_activity_role NOT IN ( 'Observer', 'Reporter' ) ;

        END IF ;

        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Assert: the only thing left to check are the various task type objects
    --
    IF l_object.object_type = 'activity' THEN

        IF l_action = 'insert' THEN

            IF l_object.status_category IN ( 'Closed', 'Not Open' ) THEN
                RETURN false ;
            END IF ;

            -- If the user is a system administrator
            -- OR the user is the owner of the parent activity (if any)
            RETURN l_acting_user.is_admin
                OR l_acting_user.user_id IS NOT DISTINCT FROM l_object.parent_owner_id ;

        ELSIF l_action IN ( 'update', 'update status', 'assign' ) THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            RETURN l_acting_user.is_admin OR l_acting_user.user_id IN ( l_object.object_owner_id, l_object.activity_owner_id ) ;

        ELSIF l_action = 'delete' THEN

            --------------------------------------------------------------------
            -- Check for time logged/sub-tasks
            FOR r IN (
                SELECT dt.id
                    FROM tasker_data.dt_task dt
                    WHERE dt.id = l_object.activity_id
                        AND (
                            EXISTS (
                                SELECT 1
                                    FROM tasker_data.dt_task sdt
                                    WHERE sdt.parent_id = dt.id
                            )
                            OR
                            EXISTS (
                                SELECT 1
                                    FROM tasker_data.dt_task_journal dtj
                                    WHERE dtj.task_id = dt.id
                                        AND coalesce ( dtj.time_spent, 0 ) > 0
                            )
                        ) ) LOOP

                RETURN false ;

            END LOOP ;

            -- If the user is a system administrator
            -- OR the user is owner of the activity
            -- OR the user is owner of the parent activity
            IF  l_acting_user.is_admin OR l_acting_user.user_id = l_object.activity_owner_id THEN
                RETURN true ;
            END IF ;

            IF l_object.parent_object_type IS NOT NULL THEN

                RETURN coalesce ( ( l_object.parent_object_type = 'activity' AND l_acting_user.user_id = l_object.parent_owner_id ), false ) ;

            END IF ;

        END IF ;

        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- All task object types other than 'activity'
    IF l_object.status_category = 'Open' THEN

        IF l_action = 'insert' THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner or assignee of the parent object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSIF l_acting_user.user_id IN ( l_object.parent_owner_id, l_object.parent_assignee_id, l_object.activity_owner_id ) THEN
                RETURN true ;
            ELSIF l_object.object_type IN ( 'pip' ) THEN
                RETURN l_user_activity_role IN ( 'Manager' ) ;
            ELSIF l_object.object_type IN ( 'requirement' ) THEN
                RETURN l_user_activity_role IN ( 'Analyst', 'Manager' ) ;
            ELSE
                RETURN l_user_activity_role IN ( 'Analyst', 'Manager', 'Member' ) ;
            END IF ;

        ELSIF l_action IN ( 'update status', 'assign' ) THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner or assignee of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.object_owner_id, l_object.object_assignee_id, l_object.activity_owner_id ) ;
            END IF ;

        ELSIF l_action = 'update' THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.object_owner_id, l_object.activity_owner_id ) ;
            END IF ;

        ELSIF l_action = 'delete' THEN

            --------------------------------------------------------------------
            -- Check for time logged/sub-tasks
            FOR r IN (
                SELECT dt.id
                    FROM tasker_data.dt_task dt
                    WHERE dt.id = l_object.object_id
                        AND (
                            EXISTS (
                                SELECT 1
                                    FROM tasker_data.dt_task sdt
                                    WHERE sdt.parent_id = dt.id
                            )
                            OR
                            EXISTS (
                                SELECT 1
                                    FROM tasker_data.dt_task_journal dtj
                                    WHERE dtj.task_id = dt.id
                                        AND coalesce ( dtj.time_spent, 0 ) > 0
                            )
                        )
                ) LOOP

                RETURN false ;

            END LOOP ;

            FOR r IN (
                SELECT dt.activity_id,
                        dtj.time_spent
                    FROM tasker_data.dt_task dt
                    JOIN tasker_data.dt_task sdt
                        ON ( sdt.parent_id = dt.id )
                    WHERE dt.activity_id = l_object.activity_id
                ) LOOP

                RETURN false ;

            END LOOP ;

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.object_owner_id, l_object.activity_owner_id ) ;
            END IF ;

        END IF ;

        RETURN false ;

    END IF ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION tasker.can_do ( text, text, text, integer, text, integer ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.can_do ( text, text, text, integer, text, integer ) IS 'Determines if the specified user can perform the specified action on the specified object.' ;
