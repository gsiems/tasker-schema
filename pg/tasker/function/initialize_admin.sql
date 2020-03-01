SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION initialize_admin (
    a_username varchar,
    a_full_name varchar,
    a_email_address varchar,
    a_password varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_test integer ;
    l_rc dml_ret ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    -- If there are no user accounts yet then we want to create the
    -- first account as an admin account.

    BEGIN

        -- Ensure that there are no user accounts yet...
        SELECT id
            INTO l_test
            FROM tasker.dt_user
            LIMIT 1 ;

        IF l_test IS NULL AND a_password IS NOT NULL THEN

            WITH a AS (
                INSERT INTO tasker.dt_user (
                        id,
                        username,
                        full_name,
                        email_address,
                        email_is_enabled,
                        is_enabled,
                        is_admin,
                        created_dt )
                    SELECT nextval ( 'dt_user_id_seq' ),
                            a_username,
                            a_full_name,
                            a_email_address,
                            true,
                            true,
                            true,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

            get diagnostics ret.numrows = row_count ;

            l_rc := user_password__set (
                a_username,
                a_password,
                a_username ) ;

            ret.err := l_rc.err ;

        ELSE
            ret.err := 'Failed to initialize admin user' ;

        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION initialize_admin (
    varchar,
    varchar,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function initialize_admin (
    varchar,
    varchar,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function initialize_admin (
    varchar,
    varchar,
    varchar,
    varchar ) FROM public ;
