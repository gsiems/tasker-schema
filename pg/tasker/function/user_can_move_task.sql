SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_move_task (
    a_task_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_activity_id integer ;
    l_parent_id integer ;

BEGIN

    IF a_task_id IS NULL OR a_task_id <= 0 THEN
        RETURN false ;
    END IF ;

    RETURN user_can_update_task (
        a_task_id,
        a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_move_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_move_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_move_task ( integer, varchar ) FROM public ;



CREATE OR REPLACE FUNCTION user_can_move_task (
    a_task_id integer,
    a_new_parent_id integer,
    a_username varchar )
RETURNS boolean
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_new_activity_id integer ;
    l_parent_id integer ;
    l_can_update_new boolean ;
    l_activity_id integer ;

BEGIN

    IF a_task_id IS NULL OR a_task_id <= 0 THEN
        RETURN false ;
    ELSIF a_task_id IS NOT DISTINCT FROM a_new_parent_id THEN
        RETURN false ;
    END IF ;

    SELECT parent_id,
            activity_id
        INTO l_parent_id,
            l_activity_id
        FROM tasker.dt_task
        WHERE id = a_task_id ;

    IF a_new_parent_id IS NOT NULL AND a_new_parent_id > 0 THEN
        -- Check for possible circular references?
        IF task_is_parent_of ( a_new_parent_id, a_task_id ) THEN
            RETURN false ;
        END IF ;

        -- Ensure that the user can update the new parent task
        l_can_update_new := user_can_update_task (
            a_new_parent_id,
            a_username ) ;

        IF NOT l_can_update_new THEN
            RETURN false ;
        END IF ;

        SELECT activity_id
            INTO l_new_activity_id
            FROM tasker.dt_task
            WHERE id = a_new_parent_id ;

        -- For Now:
        -- TODO: need an "on update cascade" foreign key between task activity_id/parent_id?
        -- If that works well then it should be possible to cleanly move tasks (with sub-tasks) between activities
        IF l_new_activity_id IS DISTINCT FROM l_activity_id THEN
            RETURN false ;
        END IF ;

    END IF ;

    RETURN user_can_update_task (
        a_task_id,
        a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_move_task ( integer, integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_move_task ( integer, integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_move_task ( integer, integer, varchar ) FROM public ;
