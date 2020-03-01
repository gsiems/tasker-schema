SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__update (
    a_task_id integer,
    a_task_type_id integer,
    a_status_id integer,
    a_priority_id integer,
    a_markup_type_id integer,
    a_desired_start date,
    a_desired_end date,
    a_estimated_start date,
    a_estimated_end date,
    a_actual_start date,
    a_actual_end date,
    a_time_estimate interval,
    a_task_name varchar,
    a_description_markup text,
    a_description_html text,
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

        IF user_can_update_task ( a_task_id, a_session_username ) THEN

            IF a_description_markup IS NULL OR length ( trim ( a_description_markup ) ) = 0 THEN
                a_description_markup := NULL ;
                a_markup_type_id := NULL ;
                a_description_html := NULL ;

            END IF ;

            WITH updated AS (
                UPDATE tasker.dt_task
                    SET task_type_id = coalesce ( a_task_type_id, task_type_id ),
                        status_id = coalesce ( a_status_id, status_id ),
                        priority_id = coalesce ( a_priority_id, priority_id ),
                        markup_type_id = a_markup_type_id,
                        desired_start = coalesce ( a_desired_start, desired_start ),
                        desired_end = coalesce ( a_desired_end, desired_end ),
                        estimated_start = coalesce ( a_estimated_start, estimated_start ),
                        estimated_end = coalesce ( a_estimated_end, estimated_end ),
                        actual_start = coalesce ( a_actual_start, actual_start ),
                        actual_end = coalesce ( a_actual_end, actual_end ),
                        time_estimate = coalesce ( a_time_estimate, time_estimate ),
                        task_name = coalesce ( trim ( a_task_name ), task_name ),
                        description_markup = a_description_markup,
                        description_html = a_description_html,
                        updated_by = l_session_user_id,
                        updated_dt = now () AT TIME ZONE 'UTC'
                    WHERE id = a_task_id
                        AND ( task_type_id IS DISTINCT FROM a_task_type_id
                            OR status_id IS DISTINCT FROM a_status_id
                            OR priority_id IS DISTINCT FROM a_priority_id
                            OR markup_type_id IS DISTINCT FROM a_markup_type_id
                            OR desired_start IS DISTINCT FROM a_desired_start
                            OR desired_end IS DISTINCT FROM a_desired_end
                            OR estimated_start IS DISTINCT FROM a_estimated_start
                            OR estimated_end IS DISTINCT FROM a_estimated_end
                            OR actual_start IS DISTINCT FROM a_actual_start
                            OR actual_end IS DISTINCT FROM a_actual_end
                            OR time_estimate IS DISTINCT FROM a_time_estimate
                            OR task_name IS DISTINCT FROM a_task_name
                            OR description_markup IS DISTINCT FROM a_description_markup
                            OR description_html IS DISTINCT FROM a_description_html )
                    RETURNING 1
            )
            SELECT count (*)
                INTO ret.id
                FROM updated ;

            get diagnostics ret.numrows = row_count ;

            UPDATE tasker.dt_task_watcher
                SET last_viewed_dt = now () AT TIME ZONE 'UTC'
                WHERE task_id = a_task_id
                    AND user_id = l_session_user_id ;

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

ALTER FUNCTION task__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    date,
    date,
    date,
    date,
    date,
    date,
    interval,
    varchar,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    date,
    date,
    date,
    date,
    date,
    date,
    interval,
    varchar,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    date,
    date,
    date,
    date,
    date,
    date,
    interval,
    varchar,
    text,
    text,
    varchar ) FROM public ;
