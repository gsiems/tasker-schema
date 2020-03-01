SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__list (
    a_activity_id integer,
    a_username varchar,
    a_session_username varchar )
RETURNS TABLE (
    ctid text,
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
    time_estimate interval,
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
    l_session_user_enabled boolean ;
    l_user_id integer ;
    l_can_select_activity boolean := false ;
    l_is_boss boolean := false ;
    l_can_select_user boolean := false ;

BEGIN

    IF a_activity_id <= 0 THEN
        a_activity_id := NULL ;
    END IF ;

    -- 1. if a_activity_id is not null then we are selecting tasks associated with a_activity_id
    -- 2. if a_username is not null then we are selecting tasks assigned to a_username
    --      a. either a_username == a_session_username, or
    --      b. a_username reports to a_session_username
    -- 3. if a_username is null then we are selecting tasks that a_session_username can see
    -- 4. either a_activity_id can be null or a_username can be null but not both

    l_user_id := user_id ( a_username ) ;
    l_session_user_id := user_id ( a_session_username ) ;

    IF l_session_user_id IS NOT NULL THEN

        SELECT u.is_enabled
            INTO l_session_user_enabled
            FROM tasker.dt_user u
            WHERE u.id = l_session_user_id ;

        IF l_session_user_enabled AND a_activity_id IS NOT NULL THEN
            l_can_select_activity := user_can_select_activity ( a_activity_id, a_session_username ) ;
        END IF ;

    END IF ;


    IF l_user_id IS NOT NULL THEN

        l_is_boss := user_is_boss_of ( l_user_id, l_session_user_id ) ;

        IF l_is_boss OR l_user_id = l_session_user_id THEN
            l_can_select_user := true ;
        END IF ;

    END IF ;

    RETURN QUERY
    SELECT dt.ctid,
            dt.task_id,
            dt.activity_id,
            dt.parent_id,
            array_to_string ( dt.parents, ',' ) AS parents,
            dt.task_depth,
            --dt.task_path,
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
        WHERE
            -- 1. we are selecting tasks associated with an activity ID, or
                ( l_can_select_activity
                    AND dt.activity_id = a_activity_id
                    )
            -- 2. we are selecting tasks assigned to a_username, or
            OR ( l_user_id IS NOT NULL
                AND l_can_select_user
                AND EXISTS (
                    SELECT 1
                        FROM tasker.dt_task_user dtu
                        WHERE dtu.task_id = dt.task_id
                            AND dtu.user_id = l_user_id )
                )
            -- 3. we are selecting tasks that a_session_username can see
            OR ( l_user_id IS NULL
                AND l_session_user_enabled
                AND EXISTS (
                    SELECT 1
                        FROM tasker.dt_task_user dtu
                        WHERE dtu.task_id = dt.task_id
                            AND dtu.user_id = l_session_user_id )
                )
        ORDER BY dt.task_path ;

END ;
$$ ;

ALTER FUNCTION task__list (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task__list (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task__list (
    integer,
    varchar,
    varchar ) FROM public ;
