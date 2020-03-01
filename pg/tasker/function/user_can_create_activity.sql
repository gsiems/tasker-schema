SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_create_activity (
    a_parent_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;
    l_user_id integer ;

BEGIN

    -- Top-level activities may only be created by administrators
    IF a_parent_id IS NULL OR a_parent_id <= 0 THEN
        RETURN user_is_admin ( a_username ) ;
    END IF ;

    -- Non top-level activities may be created by the owner of the parent
    l_user_id := user_id ( a_username ) ;

    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dtu
                ON ( dtu.user_id = du.id )
            JOIN tasker.st_role sr
                ON ( sr.id = dtu.role_id )
            WHERE du.id = l_user_id
                AND du.is_enabled
                AND dtu.activity_id = a_parent_id
                AND ( sr.is_activity_owner )
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_create_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_create_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_create_activity ( integer, varchar ) FROM public ;
