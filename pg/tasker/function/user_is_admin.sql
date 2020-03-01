SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_is_admin (
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

    l_user_id := user_id ( a_username ) ;

    FOR l_rec IN
        SELECT id
            FROM tasker.dt_user
            WHERE id = l_user_id
                AND is_admin
                AND is_enabled
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_is_admin ( varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_is_admin ( varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_is_admin ( varchar ) FROM public ;
