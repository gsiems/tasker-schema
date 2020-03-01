SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_update_task (
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
    l_activity_id integer ;

BEGIN

    IF a_task_id IS NULL OR a_task_id <= 0 THEN
        RETURN false ;
    END IF ;

    SELECT activity_id
        INTO l_activity_id
        FROM tasker.dt_task
        WHERE id = a_task_id ;

    IF l_activity_id IS NULL OR l_activity_id <= 0 THEN
        RETURN false ;
    END IF ;

    l_user_id := user_id ( a_username ) ;

    -- Tasks, for enabled activities, may be updated by the Activity Owner or a Task Manager
    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dau
                ON ( dau.user_id = du.id )
            JOIN tasker.dt_activity da
                ON ( dau.activity_id = da.id )
            JOIN tasker.st_role sr
                ON ( sr.id = dau.role_id )
            WHERE du.id = l_user_id
                AND da.is_enabled
                AND du.is_enabled
                AND dau.activity_id = l_activity_id
                AND ( sr.is_activity_owner
                    OR sr.can_create_task )
        LOOP

        RETURN true ;

    END LOOP ;

    -- Tasks, for enabled activities, may be updated by an assigned Task Updater
    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dau
                ON ( dau.user_id = du.id )
            JOIN tasker.dt_activity da
                ON ( dau.activity_id = da.id )
            JOIN tasker.st_role sr
                ON ( sr.id = dau.role_id )
            JOIN tasker.dt_task_user dtu
                ON ( dtu.user_id = du.id )
            WHERE du.id = l_user_id
                AND da.is_enabled
                AND du.is_enabled
                AND dau.activity_id = l_activity_id
                AND dtu.task_id = a_task_id
                AND sr.can_update_task
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_update_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_update_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_update_task ( integer, varchar ) FROM public ;
