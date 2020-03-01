SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_use_task (
    a_task_id integer,
    a_user_id integer )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;

BEGIN

    IF a_task_id IS NULL THEN
        RETURN false ;
    END IF ;

    -- Ensure that:
    --  the user is active and assigned to the task and that
    --  the activity is also active
    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dau
                ON ( dau.user_id = du.id )
            JOIN tasker.dt_activity da
                ON ( dau.activity_id = da.id )
            JOIN tasker.dt_task_user dtu
                ON ( dtu.user_id = du.id )
            JOIN tasker.dt_task dt
                ON ( dt.id = dtu.task_id
                    AND dt.activity_id = dau.activity_id )
            WHERE du.id = a_user_id
                AND dtu.task_id = a_task_id
                AND da.is_enabled
                AND du.is_enabled
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_use_task ( integer, integer ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_use_task ( integer, integer ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_use_task ( integer, integer ) FROM public ;



CREATE OR REPLACE FUNCTION user_can_use_task (
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
    l_user_id integer ;

BEGIN

    l_user_id := user_id ( a_username ) ;

    RETURN user_can_use_task (
        a_task_id,
        l_user_id ) ;

END ;
$$ ;

ALTER FUNCTION user_can_use_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_use_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_use_task ( integer, varchar ) FROM public ;
