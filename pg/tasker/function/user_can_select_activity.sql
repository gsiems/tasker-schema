SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_select_activity (
    a_activity_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;
    l_user_id integer ;
    l_visibility integer ;
    l_public integer := 1 ;
    l_protected integer := 2 ;
    l_private integer := 3 ;
    l_is_enabled boolean ;

BEGIN

    IF a_activity_id IS NULL OR a_activity_id <= 0 THEN
        RETURN false ;
    END IF ;

    SELECT visibility_id
        INTO l_visibility
        FROM tasker.dt_activity
        WHERE id = a_activity_id ;

    -- Public ------------------------------------------------------
    IF l_visibility = l_public THEN
        RETURN true ;
    END IF ;

    -- Ensure that the user exists and is enabled ------------------
    l_user_id := user_id ( a_username ) ;

    IF l_user_id IS NULL THEN
        RETURN false ;
    END IF ;

    SELECT is_enabled
        INTO l_is_enabled
        FROM tasker.dt_user
        WHERE id = l_user_id ;

    IF NOT l_is_enabled THEN
        RETURN false ;
    END IF ;

    -- Protected ---------------------------------------------------
    IF l_visibility = l_protected THEN
        RETURN true ;
    END IF ;

    -- Private -----------------------------------------------------

    IF user_is_admin ( a_username ) THEN
        RETURN true ;
    END IF ;

    FOR l_rec IN
        SELECT dau.user_id
            FROM tasker.dt_activity_user dau
            WHERE dau.user_id = l_user_id
                AND dau.activity_id = a_activity_id
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_select_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_select_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_select_activity ( integer, varchar ) FROM public ;
