SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__update (
    a_username varchar,
    a_full_name varchar,
    a_email_address varchar,
    a_email_is_enabled boolean,
    a_is_enabled boolean,
    a_is_admin boolean,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_user_id := user_id ( a_username ) ;
        l_session_user_id := user_id ( a_session_username ) ;

        IF l_user_id IS NULL OR l_session_user_id IS NULL THEN
            ret.err := 'Invalid argument' ;
            RETURN ret ;
        END IF ;

        IF user_is_admin ( a_session_username ) THEN

            UPDATE tasker.dt_user
                SET full_name = a_full_name,
                    email_address = a_email_address,
                    email_is_enabled = a_email_is_enabled,
                    is_enabled = a_is_enabled,
                    is_admin = a_is_admin,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = l_user_id
                    AND ( full_name IS DISTINCT FROM a_full_name
                        OR email_address IS DISTINCT FROM a_email_address
                        OR email_is_enabled IS DISTINCT FROM a_email_is_enabled
                        OR is_enabled IS DISTINCT FROM a_is_enabled
                        OR is_admin IS DISTINCT FROM a_is_admin ) ;

            get diagnostics ret.numrows = row_count ;

        ELSIF l_session_user_id = l_user_id THEN

            UPDATE tasker.dt_user
                SET full_name = a_full_name,
                    email_address = a_email_address,
                    email_is_enabled = a_email_is_enabled,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = l_user_id
                    AND ( full_name IS DISTINCT FROM a_full_name
                        OR email_address IS DISTINCT FROM a_email_address
                        OR email_is_enabled IS DISTINCT FROM a_email_is_enabled ) ;

            get diagnostics ret.numrows = row_count ;

        ELSE
            ret.err := 'Insufficient privileges' ;

        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;

END ;
$$ ;

ALTER FUNCTION user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) FROM public ;

CREATE OR REPLACE FUNCTION user__update (
    a_username varchar,
    a_full_name varchar,
    a_email_address varchar,
    a_email_is_enabled boolean,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_updater_is_admin boolean ;
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_user_id := user_id ( a_username ) ;
        l_session_user_id := user_id ( a_session_username ) ;

        IF l_user_id IS NULL OR l_session_user_id IS NULL THEN
            ret.err := 'Invalid argument' ;
            RETURN ret ;
        END IF ;

        IF user_is_admin ( a_session_username ) OR l_session_user_id = l_user_id THEN

            UPDATE tasker.dt_user
                SET full_name = trim ( a_full_name ),
                    email_address = a_email_address,
                    email_is_enabled = a_email_is_enabled,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = l_user_id
                    AND ( full_name IS DISTINCT FROM a_full_name
                        OR email_address IS DISTINCT FROM a_email_address
                        OR email_is_enabled IS DISTINCT FROM a_email_is_enabled ) ;

            get diagnostics ret.numrows = row_count ;

        ELSE
            ret.err := 'Insufficient privileges' ;

        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__update (
    varchar,
    varchar,
    varchar,
    boolean,
    varchar ) FROM public ;
