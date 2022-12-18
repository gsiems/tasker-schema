SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_file
AS
SELECT dtf.id AS file_id,
        dtf.task_id,
        dtf.edition,
        dt.task_outln,
        dt.task_name,
        dtf.comment_id,
        dtf.journal_id,
        dtf.filesize,
        dtf.filename,
        dtf.content_type,
        dtf.created_by,
        dtf.created_dt,
        dtf.updated_by,
        dtf.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_task_file dtf
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtf.task_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtf.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dtf.updated_by ) ;

ALTER TABLE dv_task_file OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_file IS 'Data view for uploaded files.' ;

REVOKE ALL ON TABLE dv_task_file FROM public ;

GRANT SELECT ON table dv_task_file TO tasker_owner ;

GRANT SELECT ON table dv_task_file TO tasker_user ;
