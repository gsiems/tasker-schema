SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__update_status (
    a_task_id integer,
    a_status_id integer,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF a_task_id IS NULL OR a_task_id <= 0 THEN
            ret.err := 'Invalid task id' ;
            RETURN ret ;
        END IF ;

        l_session_user_id := user_id ( a_session_username ) ;

        IF l_session_user_id IS NULL OR l_session_user_id <= 0 THEN
            ret.err := 'Invalid user id' ;
            RETURN ret ;
        END IF ;

        IF user_can_update_task_status ( a_task_id, a_session_username ) THEN

            WITH updated AS (
                UPDATE tasker.dt_task
                    SET status_id = a_status_id,
                        updated_by = l_session_user_id,
                        updated_dt = now () AT TIME ZONE 'UTC'
                    WHERE id = a_task_id
                        AND ( status_id IS DISTINCT FROM a_status_id )
                    RETURNING 1
            )
            SELECT count (*)
                INTO ret.id
                FROM updated ;

            get diagnostics ret.numrows = row_count ;

        ELSE
            ret.err := 'Insufficient privileges' ;

        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;

END ;
$$ ;

ALTER FUNCTION task__update_status (
    integer,
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task__update_status (
    integer,
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task__update_status (
    integer,
    integer,
    varchar ) FROM public ;
