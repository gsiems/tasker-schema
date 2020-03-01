SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_requirement
AS
SELECT dv.ctid,
        dv.task_id,
        dv.activity_id,
        dv.parent_id,
        dv.task_outln,
        dv.task_name,
        dv.task_type_id,
        dv.task_type,
        dv.status_id,
        dv.task_status,
        dv.priority_id,
        dv.task_priority,
        -- TBD
        dv.markup_type_id,
        dv.markup_type,
        --dv.actual_start,
        --dv.actual_end,
        dv.time_estimate,
        dv.description_markup,
        dv.description_html,
        dv.created_dt,
        dv.created_by,
        dv.updated_dt,
        dv.updated_by,
        dv.created_username,
        dv.created_full_name,
        dv.updated_username,
        dv.updated_full_name
    FROM tasker.dv_task dv
    JOIN tasker.dt_task_requirement dtr
        ON ( dtr.task_id = dv.task_id )
    WHERE dv.task_category_id = 2 ;

ALTER TABLE dv_requirement OWNER TO tasker_owner ;

COMMENT ON VIEW dv_requirement IS 'Data view for requirement tasks.' ;

REVOKE ALL ON table dv_requirement FROM public ;

GRANT SELECT ON table dv_requirement TO tasker_owner ;

GRANT SELECT ON table dv_requirement TO tasker_user ;
