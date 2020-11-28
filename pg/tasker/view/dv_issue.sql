SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_issue
AS
SELECT dv.edition,
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
        dv.markup_type_id,
        dv.markup_type,
        dti.probability_id,
        sip.name AS probability,
        dti.severity_id,
        sis.name AS severity,
        dti.workaround_id,
        siw.name AS workaround,
        dv.actual_start,
        dv.actual_end,
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
    JOIN tasker.dt_task_issue dti
        ON ( dti.task_id = dv.task_id )
    LEFT JOIN tasker.st_issue_probability sip
        ON ( sip.id = dti.probability_id )
    LEFT JOIN tasker.st_issue_severity sis
        ON ( sis.id = dti.severity_id )
    LEFT JOIN tasker.st_issue_workaround siw
        ON ( siw.id = dti.workaround_id )
    WHERE dv.task_category_id = 3 ;

ALTER TABLE dv_issue OWNER TO tasker_owner ;

COMMENT ON VIEW dv_issue IS 'Data view for issue tasks.' ;

REVOKE ALL ON table dv_issue FROM public ;

GRANT SELECT ON table dv_issue TO tasker_owner ;

GRANT SELECT ON table dv_issue TO tasker_user ;
