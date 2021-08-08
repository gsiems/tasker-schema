SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_association
AS
SELECT dta.task_id,
        dt.task_outln,
        dt.task_name,
        dt.status_id,
        dt.task_status,
        dt.is_open,
        dt.is_closed,
        dta.associated_task_id,
        dta.association_type_id,
        sat.name AS association_type,
        ddt.task_outln AS associated_task_outln,
        ddt.task_name AS associated_task_name,
        dt.status_id AS associated_status_id,
        dt.task_status AS associated_task_status,
        dt.is_open AS associated_is_open,
        dt.is_closed AS associated_is_closed,
        dta.created_by,
        dta.created_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name
    FROM tasker.dt_task_association dta
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dta.task_id )
    JOIN tasker.dv_task ddt
        ON ( ddt.task_id = dta.associated_task_id )
    JOIN tasker.st_association_type sat
        ON ( sat.id = dta.association_type_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dta.created_by ) ;

ALTER TABLE dv_task_association OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_association IS 'Data view for task associations.' ;

REVOKE ALL ON table dv_task_association FROM public ;

GRANT SELECT ON table dv_task_association TO tasker_owner ;

GRANT SELECT ON table dv_task_association TO tasker_user ;
