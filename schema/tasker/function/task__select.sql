SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__select (
    a_task_id integer,
    a_session_username varchar )
RETURNS TABLE (
    edition integer,
    task_id integer,
    activity_id integer,
    parent_id integer,
    parents text,
    task_depth integer,
    task_outln text,
    task_name varchar,
    task_category_id integer,
    task_category varchar,
    task_type_id integer,
    task_type varchar,
    status_id integer,
    is_open boolean,
    is_closed boolean,
    task_status varchar,
    priority_id integer,
    task_priority varchar,
    markup_type_id integer,
    markup_type varchar,
    desired_start date,
    desired_end date,
    estimated_start date,
    estimated_end date,
    actual_start date,
    actual_end date,
    time_estimate integer,
    description_markup text,
    description_html text,
    created_dt timestamp with time zone,
    created_by integer,
    updated_dt timestamp with time zone,
    updated_by integer,
    created_username varchar,
    created_full_name varchar,
    updated_username varchar,
    updated_full_name varchar )
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;

BEGIN

    l_session_user_id := user_id ( a_session_username ) ;

    UPDATE tasker.dt_task_watcher
        SET last_viewed_dt = now () AT TIME ZONE 'UTC'
        WHERE task_id = a_task_id
            AND user_id = l_session_user_id ;

    RETURN QUERY
    SELECT dt.edition,
            dt.task_id,
            dt.activity_id,
            dt.parent_id,
            array_to_string ( dt.parents, ',' ) AS parents,
            dt.task_depth,
            dt.task_outln,
            dt.task_name,
            dt.task_category_id,
            dt.task_category,
            dt.task_type_id,
            dt.task_type,
            dt.status_id,
            dt.is_open,
            dt.is_closed,
            dt.task_status,
            dt.priority_id,
            dt.task_priority,
            dt.markup_type_id,
            dt.markup_type,
            dt.desired_start,
            dt.desired_end,
            dt.estimated_start,
            dt.estimated_end,
            dt.actual_start,
            dt.actual_end,
            dt.time_estimate,
            dt.description_markup,
            dt.description_html,
            dt.created_dt,
            dt.created_by,
            dt.updated_dt,
            dt.updated_by,
            dt.created_username,
            dt.created_full_name,
            dt.updated_username,
            dt.updated_full_name
        FROM tasker.dv_task dt
        WHERE coalesce ( a_task_id, 0 ) > 0
            AND dt.task_id = a_task_id
            --AND l_session_user_id IS NOT NULL
            AND ( user_can_select_activity ( dt.activity_id, a_session_username )
                OR  -- session_user is assigned to task
                    -- or session_user is boss of user assigned to task
                    EXISTS ( SELECT 1
                            FROM tasker.dt_task_user dtu
                            WHERE dtu.task_id = dt.task_id
                                AND ( dtu.user_id = l_session_user_id
                                    OR user_is_boss_of ( dtu.user_id, l_session_user_id ) )
                    )
                ) ;

END ;
$$ ;

ALTER FUNCTION task__select (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task__select (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task__select (
    integer,
    varchar ) FROM public ;
