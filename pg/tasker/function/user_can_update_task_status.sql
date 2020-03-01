SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_update_task_status (
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
    l_rec record ;
    l_user_id integer ;

BEGIN

    IF a_task_id IS NULL THEN
        RETURN false ;
    END IF ;

    -- Task status, for enabled activities, may also be updated by any user that can update the task
    IF user_can_update_task ( a_task_id, a_username ) THEN
        RETURN true ;
    END IF ;

    -- Task status, for enabled activities, may also be updated by an assigned user
    l_user_id := user_id ( a_username ) ;

    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_task_user dtu
                ON ( dtu.user_id = du.id )
            JOIN tasker.dt_task dt
                ON ( dt.id = dtu.task_id )
            JOIN tasker.dt_activity da
                ON ( da.id = dt.activity_id )
            WHERE du.id = l_user_id
                AND da.is_enabled
                AND du.is_enabled
                AND dtu.task_id = a_task_id
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_update_task_status ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_update_task_status ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_update_task_status ( integer, varchar ) FROM public ;
