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

    l_connected_can_validate boolean := false ;

    l_acting_user tasker.ut_user_stats ;
    l_session_user tasker.ut_user_stats ;
    l_object tasker.ut_object_stats ;

    l_action text ;
    l_minimum_role integer ;

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
--RAISE NOTICE 'Fail 01' ;

        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that the action specified is valid for the object type.
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

--RAISE NOTICE E'l_action ( % )', l_action ;

    IF l_action IS NULL THEN
--RAISE NOTICE 'Fail 02' ;
        RETURN false ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that, if acting on an existing object, an object ID was provided
    IF l_object.object_type <> 'reference' AND l_object.object_id IS NULL THEN

        IF l_action IN ( 'update', 'update status', 'delete' ) THEN
--RAISE NOTICE 'Fail 03' ;
            RETURN false ;
        END IF ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that the activity, if there is one, is open for non-select actions
    -- on objects under the activity
    IF l_object.activity_id IS NOT NULL
        AND l_object.object_type <> 'activity'
        AND l_action <> 'select'
        AND l_object.open_category <> 'Open' THEN

--RAISE NOTICE 'Fail 04' ;
        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that there is an acting user and that they are enabled
    l_acting_user := tasker.get_user_stats ( a_user => a_user ) ;
--RAISE NOTICE E'l_acting_user ( % )', l_acting_user ;
    IF NOT ( l_acting_user.user_id IS NOT NULL AND l_acting_user.is_enabled ) THEN
--RAISE NOTICE 'Fail 05' ;
        RETURN false ;
    END IF ;

    -- Ensure that there is a connected user, they are enabled, and that they are not, somehow, a "public" user
    l_session_user := tasker.get_user_stats ( a_user => session_user::text ) ;
--RAISE NOTICE E'l_session_user ( % )', l_session_user ;
    IF NOT ( l_session_user.user_id IS NOT NULL AND l_session_user.is_enabled ) THEN
--RAISE NOTICE 'Fail 06' ;
        RETURN false ;
    ELSIF l_session_user.is_public THEN
--RAISE NOTICE 'Fail 07' ;
        RETURN false ;
    END IF ;

    -- Determine if the connected user is sufficient for validating actions for
    -- the acting user-- which means that either the acting user is the connected
    -- (database session) user or that the connected user is an administrator
    l_connected_can_validate := l_session_user.is_admin OR l_acting_user.user_id = l_session_user.user_id ;
--RAISE NOTICE E'l_connected_can_validate ( % )', l_connected_can_validate ;

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    --
    IF l_object.object_type = 'reference' THEN

        -- admins can do whatever and known users can select
        IF l_action = 'select' THEN
            RETURN l_connected_can_validate AND NOT l_acting_user.is_public ;
        ELSE
            RETURN l_acting_user.is_admin AND l_connected_can_validate ;
        END IF ;

    END IF ;

    IF l_object.object_type = 'user' THEN

       RETURN l_acting_user.is_admin AND l_connected_can_validate ;

    END IF ;

    IF l_object.object_type = 'profile' THEN

        RETURN l_acting_user.user_id = a_id
            AND l_action IN ( 'select', 'insert', 'update' )
            AND l_connected_can_validate ;

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
    l_minimum_role := tasker.get_minimum_required_role (
        a_action => l_action,
        a_object_type => l_object.object_type ) ;

    ----------------------------------------------------------------------------
    IF l_object.object_type = 'journal' THEN

        IF l_action NOT IN ( 'select', 'insert', 'update', 'delete' ) THEN
            RETURN false ;
        ELSIF l_acting_user.is_public THEN
            RETURN false ;
        END IF ;


        IF l_action = 'select' THEN

            -- Users may select from their journal entries
            IF l_object.object_owner_id = l_acting_user.user_id
                AND l_connected_can_validate THEN

                RETURN true ;

            ELSE

                -- Supervisors/managers may select from the journal entries of their reports
                FOR r IN (
                    SELECT 1
                        FROM tasker.dv_user_reporting_chain
                        WHERE user_id = l_object.object_owner_id
                            AND l_acting_user.user_id = ANY ( reporting_chain )
                            AND l_connected_can_validate
                    ) LOOP

                    RETURN true ;

                END LOOP ;

            END IF ;

        ELSIF l_action IN ( 'update', 'delete' ) THEN

            RETURN l_object.object_owner_id = l_acting_user.user_id
                AND l_connected_can_validate ;

        ELSIF l_action = 'insert' THEN

            -- must be assigned to the parent object
            -- OR be owner of the parent object
            -- OR be a member of the activity with a role >= Member

            IF l_acting_user.user_id IN ( l_object.parent_owner_id, l_object.parent_assignee_id )
                AND l_connected_can_validate THEN

                RETURN true ;

            END IF ;

            FOR r IN (
                SELECT user_id
                    FROM tasker.dv_activity_member
                    WHERE activity_id = l_object.activity_id
                        AND role_id >= l_minimum_role
                        AND user_id = l_acting_user.user_id
                        AND l_connected_can_validate ) LOOP

                RETURN true ;

            END LOOP ;

        END IF ;

        RETURN false ;

    END IF ;

    IF l_object.object_type = 'comment' THEN


        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Assert: the only thing left to check are the various task type objects
    --
    IF l_action = 'select' THEN

        -- data for public activities may be selected
        -- data for protected activities may be selected by known users
        -- data for private activities may only be selected by activity members
        IF l_object.activity_visibility = 'Public' THEN
            RETURN true ;
        END IF ;

        IF l_object.activity_visibility = 'Protected' THEN

            IF l_acting_user.is_public THEN
                RETURN false ;
            ELSE
                RETURN l_connected_can_validate ;
            END IF ;

        END IF ;

        IF l_object.activity_visibility = 'Private' THEN

            FOR r IN (
                SELECT user_id
                    FROM tasker_data.dt_activity_member
                    WHERE activity_id = l_object.activity_id
                        AND user_id = l_acting_user.user_id
                        AND l_connected_can_validate ) LOOP

                RETURN true ;

            END LOOP ;

        END IF ;

        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    IF NOT l_connected_can_validate THEN
        RETURN false ;
    END IF ;

    IF l_object.object_type = 'activity' THEN

        IF l_action = 'insert' THEN

            -- If the user is a system administrator
            -- OR the user has create activity permission
            -- OR the user is the owner of the parent activity
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSIF l_object.parent_object_type IS NULL THEN
                RETURN l_acting_user.can_create_activities ;
            ELSE
                RETURN l_object.parent_owner_id = l_acting_user.user_id ;
            END IF ;

        ELSIF l_action IN ( 'update', 'update status', 'assign' ) THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.owner_id, l_object.activity_owner_id ) ;
            END IF ;

        ELSIF l_action = 'delete' THEN

            -- TODO
            -- check for sub-objects/time logged

            -- If the user is a system administrator
            -- OR the user is owner of the parent activity
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSIF l_object.parent_object_type = 'activity' THEN
                RETURN l_acting_user.user_id = l_object.parent_owner_id ;
            END IF ;

        END IF ;

        RETURN false ;

    ELSIF l_object.open_category = 'Open' THEN

        IF l_action = 'insert' THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner or assignee of the parent object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSIF l_acting_user.user_id IN ( l_object.parent_owner_id, l_object.parent_assignee_id, l_object.activity_owner_id ) THEN
                RETURN true ;
            ELSE

                FOR r IN (
                    SELECT user_id
                        FROM tasker.dv_activity_member
                        WHERE activity_id = l_object.activity_id
                            AND role_id >= l_minimum_role
                            AND user_id = l_acting_user.user_id
                            AND l_connected_can_validate ) LOOP

                    RETURN true ;

                END LOOP ;

            END IF ;

        ELSIF l_action IN ( 'update status', 'assign' ) THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner or assignee of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.owner_id, l_object.object_assignee_id, l_object.activity_owner_id ) ;
            END IF ;

        ELSIF l_action = 'update' THEN

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.owner_id, l_object.activity_owner_id ) ;
            END IF ;

        ELSIF l_action = 'delete' THEN

            -- TODO: check for sub-objects/time logged

            -- If the user is a system administrator
            -- OR the user is the activity owner
            -- OR the user is the owner of the object
            IF l_acting_user.is_admin THEN
                RETURN true ;
            ELSE
                RETURN l_acting_user.user_id IN ( l_object.owner_id, l_object.activity_owner_id ) ;
            END IF ;

        END IF ;

        RETURN false ;

    END IF ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION tasker.can_do ( text, text, text, integer, text, integer ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.can_do ( text, text, text, integer, text, integer ) IS 'Determines if the specified user can perform the specified action on the specified object.' ;
