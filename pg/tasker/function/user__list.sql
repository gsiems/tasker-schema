SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__list (
    a_session_username varchar )
RETURNS TABLE (
        user_id integer,
        username varchar,
        full_name varchar,
        email_address varchar,
        is_enabled boolean )
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;

BEGIN

    l_session_user_id := user_id ( a_session_username ) ;

    RETURN QUERY
    SELECT du.user_id,
            du.username,
            du.full_name,
            du.email_address,
            du.is_enabled
        FROM tasker.dv_user du
        WHERE l_session_user_id IS NOT NULL ;

END ;
$$ ;

ALTER FUNCTION user__list (
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user__list (
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user__list (
    varchar ) FROM public ;
