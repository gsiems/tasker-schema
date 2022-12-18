SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_password__set (
    a_username varchar,
    a_password varchar,
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
    l_digest text ;
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

            l_digest := crypt ( a_password, gen_salt ( 'bf', 8 ) ) ;

            WITH ct AS (
                SELECT count (*) AS kount
                    FROM tasker.dt_user_password
                    WHERE user_id = l_user_id
            ),
            n AS (
                INSERT INTO tasker.dt_user_password (
                        user_id,
                        password_hash,
                        created_by,
                        created_dt )
                    SELECT l_user_id,
                            l_digest,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC'
                        FROM ct
                        WHERE ct.kount = 0
            )
            UPDATE tasker.dt_user_password
                SET password_hash = l_digest,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                FROM ct
                WHERE user_id = l_user_id
                    AND ct.kount = 1 ;

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

ALTER FUNCTION user_password__set ( varchar, varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user_password__set ( varchar, varchar, varchar ) TO tasker_user ;

REVOKE ALL ON function user_password__set ( varchar, varchar, varchar ) FROM public ;


CREATE OR REPLACE FUNCTION user_password__set (
    a_username varchar,
    a_password varchar,
    a_old_password varchar,
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
    l_digest text ;
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

        -- TODO: maybe add "algorithm" column in case algorithm is ever updated?
        IF l_session_user_id = l_user_id THEN

            l_digest := crypt ( a_password, gen_salt ( 'bf', 8 ) ) ;

            WITH ct AS (
                SELECT count (*) AS kount
                    FROM tasker.dt_user_password
                    WHERE user_id = l_user_id
                        AND password_hash = crypt ( a_old_password, password_hash )
            )
            UPDATE tasker.dt_user_password
                SET password_hash = l_digest,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                FROM ct
                WHERE user_id = l_user_id
                    AND ct.kount = 1 ;

            get diagnostics ret.numrows = row_count ;

            IF ret.numrows = 0 THEN
                ret.err := 'Failed to set password' ;
            END IF ;

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

ALTER FUNCTION user_password__set ( varchar, varchar, varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user_password__set ( varchar, varchar, varchar, varchar ) TO tasker_user ;

REVOKE ALL ON function user_password__set ( varchar, varchar, varchar, varchar ) FROM public ;
