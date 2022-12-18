SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__insert (
    a_supervisor_id integer,
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

        IF a_username IS NULL OR trim ( a_username ) = '' THEN
            ret.err := 'Invalid username' ;
            RETURN ret ;
        END IF ;

        -- Numeric usernames are not allowed, alpha-numeric are fine
        IF a_username ~ '^\d+$' THEN
            ret.err := 'Invalid username' ;
            RETURN ret ;
        END IF ;

        -- No commas, semi-colons, etc. either
        IF a_username ~ '[,;|]' THEN
            ret.err := 'Invalid username' ;
            RETURN ret ;
        END IF ;

        IF user_is_admin ( a_session_username ) THEN

            l_session_user_id := user_id ( a_session_username ) ;

            WITH a AS (
                INSERT INTO tasker.dt_user (
                        id,
                        supervisor_id,
                        username,
                        full_name,
                        email_address,
                        email_is_enabled,
                        is_enabled,
                        is_admin,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'dt_user_id_seq' ),
                            CASE
                                WHEN a_supervisor_id <= 0 THEN NULL
                                ELSE a_supervisor_id
                                END,
                            trim ( a_username ),
                            trim ( a_full_name ),
                            a_email_address,
                            a_email_is_enabled,
                            a_is_enabled,
                            a_is_admin,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

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

ALTER FUNCTION user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar ) FROM public ;

CREATE OR REPLACE FUNCTION user__insert (
    a_supervisor_id integer,
    a_username varchar,
    a_full_name varchar,
    a_email_address varchar,
    a_email_is_enabled boolean,
    a_is_enabled boolean,
    a_is_admin boolean,
    a_password varchar,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    ret dml_ret ;
    ret2 dml_ret ;

BEGIN

    ret := user__insert (
        a_supervisor_id,
        a_username,
        a_full_name,
        a_email_address,
        a_email_is_enabled,
        a_is_enabled,
        a_is_admin,
        a_session_username ) ;

    IF ret.id IS NOT NULL THEN

        ret2 := user_password__set (
            a_username,
            a_password,
            a_session_username ) ;

        IF ret2.err IS NOT NULL THEN
            ret.err := ret2.err ;
        END IF ;

    END IF ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__insert (
    integer,
    varchar,
    varchar,
    varchar,
    boolean,
    boolean,
    boolean,
    varchar,
    varchar ) FROM public ;
