SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_watcher
AS
SELECT dtw.user_id,
        du.username,
        du.full_name,
        du.is_enabled AS user_is_enabled,
        du.email_address,
        du.email_is_enabled,
        dtw.task_id,
        dt.task_outln,
        dt.task_name,
        dtw.created_by,
        dtw.created_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name
    FROM tasker.dt_task_watcher dtw
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtw.task_id )
    JOIN tasker.dt_user du
        ON ( du.id = dtw.user_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtw.created_by ) ;

ALTER TABLE dv_task_watcher OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_watcher IS 'Data view for task watchers.' ;

REVOKE ALL ON table dv_task_watcher FROM public ;

GRANT SELECT ON table dv_task_watcher TO tasker_owner ;

GRANT SELECT ON table dv_task_watcher TO tasker_user ;
