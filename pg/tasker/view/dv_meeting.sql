SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_meeting
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
        dtm.meeting_location,
        dtm.scheduled_start,
        dv.time_estimate AS scheduled_duration,
        dtm.agenda_markup,
        dtm.agenda_html,
        dtm.minutes_markup,
        dtm.minutes_html,
        dv.created_dt,
        dv.created_by,
        dv.updated_dt,
        dv.updated_by,
        dv.created_username,
        dv.created_full_name,
        dv.updated_username,
        dv.updated_full_name
    FROM tasker.dv_task dv
    JOIN tasker.dt_task_meeting dtm
        ON ( dtm.task_id = dv.task_id )
    --LEFT JOIN tasker.st_markup_type smt
    --    ON ( smt.id = dtm.markup_type_id )
    WHERE dv.task_category_id = 4 ;

ALTER TABLE dv_meeting OWNER TO tasker_owner ;

COMMENT ON VIEW dv_meeting IS 'Data view for meeting tasks.' ;

REVOKE ALL ON table dv_meeting FROM public ;

GRANT SELECT ON table dv_meeting TO tasker_owner ;

GRANT SELECT ON table dv_meeting TO tasker_user ;
