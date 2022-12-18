SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_token__set (
    a_username varchar,
    a_token varchar,
    a_idle_timeout integer )
RETURNS boolean
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    r record ;

BEGIN

    -- Ensure the account exists
    l_user_id := user_id ( a_username ) ;
    IF l_user_id IS NULL THEN
        RETURN false ;
    END IF ;

    -- Ensure the account is open
    FOR r IN (
        SELECT u.id
            FROM tasker.dt_user u
            WHERE u.id = l_user_id
                AND u.is_enabled ) LOOP

        INSERT INTO tasker.dt_user_token (
                user_id,
                token,
                a_idle_timeout,
                updated_dt )
            SELECT r.id,
                    a_token,
                    coalesce ( a_idle_timeout, 0 ),
                    now () AT TIME ZONE 'UTC'
                WHERE NOT EXISTS (
                    SELECT 1
                        FROM tasker.dt_user_token
                        WHERE user_id = r.id
                    ) ;

        UPDATE tasker.dt_user_token
            SET token = a_token,
                a_idle_timeout = coalesce ( a_idle_timeout, 0 ),
                updated_dt = now () AT TIME ZONE 'UTC'
            WHERE user_id = r.id ;

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_token__set ( varchar, varchar, integer ) OWNER TO tasker_owner ;

GRANT ALL ON function user_token__set ( varchar, varchar, integer ) TO tasker_user ;

REVOKE ALL ON function user_token__set ( varchar, varchar, integer ) FROM public ;
