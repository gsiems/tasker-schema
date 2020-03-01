SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_move_activity (
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

BEGIN

    IF a_activity_id IS NULL OR a_activity_id <= 0 THEN
        RETURN false ;
    END IF ;

    RETURN user_can_update_activity (
        a_activity_id,
        a_username );

END ;
$$ ;

ALTER FUNCTION user_can_move_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_move_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_move_activity ( integer, varchar ) FROM public ;


CREATE OR REPLACE FUNCTION user_can_move_activity (
    a_activity_id integer,
    a_new_parent_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_can_update_new boolean ;

BEGIN

    IF a_activity_id IS NULL OR a_activity_id <= 0 THEN
        RETURN false ;
    ELSIF a_activity_id IS NOT DISTINCT FROM a_new_parent_id THEN
        RETURN false ;
    END IF ;

    IF a_new_parent_id IS NOT NULL AND a_new_parent_id > 0 THEN
        -- Check for possible circular references?
        IF activity_is_parent_of ( a_new_parent_id, a_activity_id ) THEN
            RETURN false ;
        END IF ;

        -- Ensure that the user can update the new parent activity
        l_can_update_new := user_can_update_activity (
            a_new_parent_id,
            a_username ) ;

        IF NOT l_can_update_new THEN
            RETURN false ;
        END IF ;
    END IF ;

    -- Ensure that the user can update the activity
    RETURN user_can_update_activity (
        a_activity_id,
        a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_move_activity ( integer, integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_move_activity ( integer, integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_move_activity ( integer, integer, varchar ) FROM public ;
