SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__insert (
    a_parent_id integer,
    a_activity_id integer,
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

        IF user_can_create_task ( a_parent_id, a_activity_id, a_session_username ) THEN

            IF a_task_name IS NULL OR trim ( a_task_name ) = '' THEN
                ret.err := 'Invalid task name' ;
                RETURN ret ;
            END IF ;

            IF a_description_markup IS NULL OR length ( trim ( a_description_markup ) ) = 0 THEN
                a_description_markup := NULL ;
                a_markup_type_id := NULL ;
                a_description_html := NULL ;

            END IF ;

            l_session_user_id := user_id ( a_session_username ) ;

            WITH a AS (
                INSERT INTO tasker.dt_task (
                        id,
                        parent_id,
                        activity_id,
                        task_type_id,
                        status_id,
                        priority_id,
                        markup_type_id,
                        desired_start,
                        desired_end,
                        estimated_start,
                        estimated_end,
                        actual_start,
                        actual_end,
                        time_estimate,
                        task_name,
                        description_markup,
                        description_html,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'dt_task_id_seq' ),
                            CASE
                                WHEN a_parent_id <= 0 THEN NULL
                                ELSE a_parent_id
                                END,
                            a_activity_id,
                            CASE
                                WHEN a_task_type_id <= 0 THEN 1
                                ELSE a_task_type_id
                                END,
                            CASE
                                WHEN a_status_id <= 0 THEN NULL
                                ELSE a_status_id
                                END,
                            CASE
                                WHEN a_priority_id <= 0 THEN NULL
                                ELSE a_priority_id
                                END,
                            CASE
                                WHEN a_markup_type_id <= 0 THEN NULL
                                ELSE a_markup_type_id
                                END,
                            a_desired_start,
                            a_desired_end,
                            a_estimated_start,
                            a_estimated_end,
                            a_actual_start,
                            a_actual_end,
                            a_time_estimate,
                            trim ( a_task_name ),
                            a_description_markup,
                            a_description_html,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

            get diagnostics ret.numrows = row_count ;

            -- Set the owner
            INSERT INTO tasker.dt_task_user (
                    task_id,
                    user_id,
                    created_by,
                    created_dt )
                SELECT ret.id,
                        l_session_user_id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC' ;

            -- Add autowatch for the task.
            IF a_parent_id IS NULL THEN
                -- If this is a top level task then add the activity members.
                INSERT INTO tasker.dt_task_watcher (
                        task_id,
                        user_id,
                        created_by,
                        created_dt )
                    SELECT ret.id,
                            user_id,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC'
                        FROM tasker.dt_activity_user
                            WHERE activity_id = a_activity_id ;

            ELSE
                -- If otherwise (this is a sub-task) then copy any parent task watchers.
                INSERT INTO tasker.dt_task_watcher (
                        task_id,
                        user_id,
                        created_by,
                        created_dt )
                    SELECT ret.id,
                            user_id,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC'
                        FROM tasker.dt_task_watcher
                            WHERE task_id = a_parent_id ;

            END IF ;

            -- Add the task creater to the watch list
            INSERT INTO tasker.dt_task_watcher (
                    task_id,
                    user_id,
                    last_viewed_dt,
                    created_by,
                    created_dt )
                SELECT ret.id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC',
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC'
                    WHERE NOT EXISTS (
                        SELECT 1
                            FROM tasker.dt_task_watcher
                            WHERE task_id = ret.id
                                AND user_id = l_session_user_id
                        ) ;

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

ALTER FUNCTION task__insert (
    integer,
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

GRANT ALL ON FUNCTION task__insert (
    integer,
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

REVOKE ALL ON FUNCTION task__insert (
    integer,
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
    varchar ) FROM public
