set search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_id (
    a_username varchar )
RETURNS integer
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;

BEGIN

    -- Determine the user_id
    SELECT u.id
        INTO l_user_id
        FROM tasker.dt_user u
        WHERE u.username = a_username ;

    IF l_user_id IS NULL THEN

        -- Check to see if the function was called with the user_id instead
        SELECT u.id
            INTO l_user_id
            FROM tasker.dt_user u
            WHERE a_username ~ '^\d+$'
                AND u.id = a_username::integer ;

    END IF ;

    RETURN l_user_id ;
END ;
$$ ;

ALTER FUNCTION user_id ( varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user_id ( varchar ) TO tasker_user ;

REVOKE ALL ON function user_id ( varchar ) FROM public ;
