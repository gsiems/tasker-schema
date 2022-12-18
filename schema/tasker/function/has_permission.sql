CREATE OR REPLACE FUNCTION tasker.has_permission (
    a_activity_id integer default null,
    a_minimum_role_id integer default null,
    a_minimum_role text default null,
    a_user_id integer default null )
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function has_permission determines if a user has the minimum required role permission

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_activity_id                  | in     | integer    | The activity to check permissions for              |
| a_minimum_role_id              | in     | integer    | The ID of the minimum level role that the user needs to have |
| a_minimum_role                 | in     | text       | The name of minimum level role that the user needs to have |
| a_user_id                      | in     | integer    | The user ID to check permissions for               |

*/
DECLARE

    r record ;

    l_connected_user_id integer ;
    l_minimum_role_id integer ;

    l_acting_user_role_id smallint ;
    l_connected_user_role_id smallint ;

BEGIN

    -- NB: For web applications the connected user should differ from the
    --  specified user. Therefore, to mitigate potential privilege escalation
    --  issues it is necessary to ensure that both the specified acting user
    --  AND the connected user have the minimum required role.

    -- NB: If no activity ID is specified then it is asserted that the
    --  permissions being sought are for administrative purposes.

    l_minimum_role_id := tasker.resolve_role_id (
        a_id => a_minimum_role_id,
        a_name => a_minimum_role ) ;

    ----------------------------------------------------------------------------
    -- Get the role for the specified user

    -- Check if the acting user has the "System Administrator" role
    -- Assertion: the highest role ID corresponds to the system admin role
    FOR r IN (
        SELECT max ( id ) AS role_id
            FROM tasker_data.st_role
            WHERE is_enabled
                AND EXISTS (
                    SELECT 1
                        FROM tasker_data.dt_user
                        WHERE is_admin
                            AND is_enabled
                            AND id = a_user_id )
        ) LOOP

        l_acting_user_role_id := r.role_id ;

    END LOOP ;

    IF l_acting_user_role_id IS NULL THEN

        -- Determine the role that the acting user has in the specified activity
        FOR r IN (
            SELECT role_id
                FROM tasker_data.dt_activity_member
                WHERE activity_id = a_activity_id
                    AND user_id = a_user_id ) LOOP

            l_acting_user_role_id := r.role_id ;

        END LOOP ;

    END IF ;

    IF l_acting_user_role_id IS NULL
        OR l_acting_user_role_id < l_minimum_role_id THEN

        RETURN false ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Get the role for the connected user
    l_connected_user_id := tasker.resolve_user_id ( a_user => session_user::text ) ;

    IF l_connected_user_id = a_user_id THEN
        l_connected_user_role_id := l_acting_user_role_id ;
    END IF ;

    IF l_connected_user_role_id IS NULL THEN

        -- Check if the connected user has the "System Administrator" role
        FOR r IN (
            SELECT max ( id ) AS role_id
                FROM tasker_data.st_role
                WHERE is_enabled
                    AND EXISTS (
                        SELECT 1
                            FROM tasker_data.dt_user
                            WHERE is_admin
                                AND is_enabled
                                AND id = l_connected_user_id )
            ) LOOP

            l_connected_user_role_id := r.role_id ;

        END LOOP ;

    END IF ;

    IF l_connected_user_role_id IS NULL THEN

        -- Determine the role that the user has in the specified activity
        FOR r IN (
            SELECT role_id
                FROM tasker_data.dt_activity_member
                WHERE activity_id = a_activity_id
                    AND user_id = l_connected_user_id ) LOOP

            l_connected_user_role_id := r.role_id ;

        END LOOP ;

    END IF ;

    ----------------------------------------------------------------------------
    IF l_acting_user_role_id IS NOT NULL
        AND l_connected_user_role_id IS NOT NULL
        AND l_acting_user_role_id >= l_minimum_role_id
        AND l_connected_user_role_id >= l_minimum_role_id THEN

        RETURN true ;

    END IF ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION tasker.has_permission ( integer, integer, text, integer ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.has_permission ( integer, integer, text, integer ) IS 'Determines if a user has the minimum required role permission' ;
