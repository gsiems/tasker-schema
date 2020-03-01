SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_create_task (
    a_parent_id integer,
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

BEGIN

    IF a_activity_id IS NULL THEN
        RETURN false ;
    END IF ;

    l_user_id := user_id ( a_username ) ;

    -- Tasks may be created by the Activity Owner or a Task Manager
    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dau
                ON ( dau.user_id = du.id )
            JOIN tasker.dt_activity da
                ON ( da.id = dau.activity_id )
            JOIN tasker.st_role sr
                ON ( sr.id = dau.role_id )
            WHERE du.id = l_user_id
                AND du.is_enabled
                AND da.is_enabled
                AND dau.activity_id = a_activity_id
                AND ( sr.is_activity_owner
                    OR sr.can_create_task )
        LOOP

        RETURN true ;

    END LOOP ;

    -- Sub-Tasks may also be created by a Task Updater for the parent task
    IF a_parent_id IS NOT NULL THEN

        FOR l_rec IN
            SELECT du.id
                FROM tasker.dt_user du
                JOIN tasker.dt_activity_user dau
                    ON ( dau.user_id = du.id )
                JOIN tasker.dt_activity da
                    ON ( da.id = dau.activity_id )
                JOIN tasker.st_role sr
                    ON ( sr.id = dau.role_id )
                JOIN tasker.dt_task_user dtu
                    ON ( dtu.user_id = du.id )
                WHERE du.id = l_user_id
                    AND du.is_enabled
                    AND da.is_enabled
                    AND dau.activity_id = a_activity_id
                    AND dtu.task_id = a_parent_id
                    AND ( sr.can_update_task )
            LOOP

            RETURN true ;

        END LOOP ;

    END IF ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_create_task ( integer, integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_create_task ( integer, integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_create_task ( integer, integer, varchar ) FROM public ;
