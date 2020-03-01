SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_dependency
AS
SELECT dtd.task_id,
        dt.task_outln,
        dt.task_name,
        dt.status_id,
        dt.task_status,
        dt.is_open,
        dt.is_closed,
        dtd.dependent_task_id,
        ddt.task_outln AS dependent_task_outln,
        ddt.task_name AS dependent_task_name,
        dt.status_id AS dependent_status_id,
        dt.task_status AS dependent_task_status,
        dt.is_open AS dependent_is_open,
        dt.is_closed AS dependent_is_closed,
        dtd.created_by,
        dtd.created_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name
    FROM tasker.dt_task_dependency dtd
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtd.task_id )
    JOIN tasker.dv_task ddt
        ON ( ddt.task_id = dtd.dependent_task_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtd.created_by ) ;

ALTER TABLE dv_task_dependency OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_dependency IS 'Data view for task dependencies.' ;

REVOKE ALL ON table dv_task_dependency FROM public ;

GRANT SELECT ON table dv_task_dependency TO tasker_owner ;

GRANT SELECT ON table dv_task_dependency TO tasker_user ;
