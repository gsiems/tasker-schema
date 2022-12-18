CREATE OR REPLACE FUNCTION tasker.is_system_admin (
    a_id in integer default null,
    a_user in text default null )
RETURNS boolean
STABLE
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
/**
Function is_system_admin determines if the specified user is a system administrator

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | integer    | Unique ID for the user account.                    |
| a_user                         | in     | text       | The username (or ID) associated with the account.  |

*/
DECLARE

    r record ;
    l_user_id integer ;

BEGIN

    l_user_id := tasker.resolve_user_id (
        a_id => a_id,
        a_user => a_user ) ;

    FOR r IN
        ( SELECT id
            FROM tasker_data.dt_user
            WHERE id = l_user_id
                AND is_admin
                AND is_enabled ) LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION tasker.is_system_admin ( integer, text ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.is_system_admin ( integer, text ) IS 'Determines if the specified user is a system administrator' ;
