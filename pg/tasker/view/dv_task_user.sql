SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_user
AS
SELECT dtu.user_id,
        du.username,
        du.full_name,
        du.is_enabled AS user_is_enabled,
        du.email_address,
        du.email_is_enabled,
        dtu.task_id,
        dt.activity_id,
        --dt.task_depth,
        dt.task_outln,
        dt.task_name,
        rtt.category_id AS task_category_id,
        tc.name AS task_category,
        dt.task_type_id,
        dt.task_type,
        dt.status_id,
        dt.is_open,
        dt.is_closed,
        dt.task_status,
        dt.priority_id,
        dt.task_priority,
        --dt.desired_start,
        --dt.desired_end,
        --dt.estimated_start,
        --dt.estimated_end,
        dt.actual_start,
        dt.actual_end,
        dt.time_estimate,
        dtu.created_by,
        dtu.created_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name
    FROM tasker.dt_task_user dtu
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtu.task_id )
    JOIN tasker.rt_task_type rtt
        ON ( rtt.id = dt.task_type_id )
    JOIN tasker.st_task_category tc
        ON ( tc.id = rtt.category_id )
    JOIN tasker.dt_user du
        ON ( du.id = dtu.user_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtu.created_by ) ;

ALTER TABLE dv_task_user OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_user IS 'Data view for task users.' ;

REVOKE ALL ON table dv_task_user FROM public ;

GRANT SELECT ON table dv_task_user TO tasker_owner ;

GRANT SELECT ON table dv_task_user TO tasker_user ;
