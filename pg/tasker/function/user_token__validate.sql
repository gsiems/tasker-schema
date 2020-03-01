SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_token__validate (
    a_username varchar,
    a_token varchar )
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

    l_user_id := user_id ( a_username ) ;

    IF l_user_id IS NULL THEN
        RETURN false ;
    END IF ;

    FOR r IN (
        SELECT u.id
            FROM tasker.dt_user u
            JOIN tasker.dt_user_token t
                ON ( t.user_id = u.id )
            WHERE u.id = l_user_id
                AND u.is_enabled
                AND t.token = a_token
                AND t.updated_dt + ( t.idle_timeout::text || ' seconds' )::interval > now () AT TIME ZONE 'UTC'
        ) LOOP

        UPDATE tasker.dt_user_token
            SET updated_dt = now () AT TIME ZONE 'UTC'
            WHERE user_id = r.id ;

        RETURN true ;
    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_token__validate ( varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user_token__validate ( varchar, varchar ) TO tasker_user ;

REVOKE ALL ON function user_token__validate ( varchar, varchar ) FROM public ;
