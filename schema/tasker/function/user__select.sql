SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__select (
    a_username varchar,
    a_session_username varchar )
RETURNS TABLE (
        edition integer,
        user_id integer,
        supervisor_id integer,
        reporting_chain text,
        user_depth integer,
        user_outln text,
        username varchar,
        full_name varchar,
        email_address varchar,
        email_is_enabled boolean,
        is_enabled boolean,
        is_admin boolean,
        last_login timestamp with time zone,
        created_by integer,
        created_dt timestamp with time zone,
        updated_by integer,
        updated_dt timestamp with time zone,
        created_username varchar,
        created_full_name varchar,
        updated_username varchar,
        updated_full_name varchar )
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;
    l_user_id integer ;
    l_is_admin boolean ;

BEGIN

    l_user_id := user_id ( a_username ) ;
    l_session_user_id := user_id ( a_session_username ) ;
    l_is_admin := user_is_admin ( a_session_username ) ;

    RETURN QUERY
    SELECT du.edition,
            du.user_id,
            du.supervisor_id,
            array_to_string ( du.reporting_chain, ',' ) AS reporting_chain,
            du.user_depth,
            du.user_outln,
            du.username,
            du.full_name,
            du.email_address,
            du.email_is_enabled,
            du.is_enabled,
            du.is_admin,
            du.last_login,
            du.created_by,
            du.created_dt,
            du.updated_by,
            du.updated_dt,
            du.created_username,
            du.created_full_name,
            du.updated_username,
            du.updated_full_name
        FROM tasker.dv_user du
        WHERE du.user_id = l_user_id
            AND ( l_is_admin
                OR l_session_user_id = l_user_id
                OR l_session_user_id = ANY ( du.reporting_chain ) ) ;

END ;
$$ ;

ALTER FUNCTION user__select (
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user__select (
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user__select (
    varchar,
    varchar ) FROM public ;
