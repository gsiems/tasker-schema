SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_select_task (
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

BEGIN

    IF a_task_id IS NULL THEN
        RETURN false ;
    END IF ;

    SELECT activity_id
        INTO l_activity_id
        FROM tasker.dt_task
        WHERE id = a_task_id ;

    RETURN user_can_select_activity ( l_activity_id, a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_select_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_select_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_select_task ( integer, varchar ) FROM public ;
