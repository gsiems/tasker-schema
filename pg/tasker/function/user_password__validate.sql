SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_password__validate (
    a_username varchar,
    a_password varchar )
RETURNS boolean
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_matches bool ;

BEGIN

    l_user_id := user_id ( a_username ) ;

    IF l_user_id IS NULL THEN
        RETURN false ;
    END IF ;

    SELECT password_hash = crypt ( a_password, password_hash )
        INTO l_matches
        FROM tasker.dt_user_password
        WHERE user_id = l_user_id ;

    -- TODO: Do we wish to log failed validations?

    RETURN l_matches ;
END ;
$$ ;

ALTER FUNCTION user_password__validate ( varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user_password__validate ( varchar, varchar ) TO tasker_user ;

REVOKE ALL ON function user_password__validate ( varchar, varchar ) FROM public ;
