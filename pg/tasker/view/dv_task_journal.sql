SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_journal
AS
SELECT dtj.id AS journal_id,
        dtj.task_id,
        dtj.edition,
        dt.task_outln,
        dt.task_name,
        dtj.user_id,
        du.username,
        du.full_name,
        dtj.journal_date,
        dtj.time_spent,
        dtj.markup_type_id,
        smt.name AS markup_type,
        dtj.journal_markup,
        dtj.journal_html,
        dtj.created_by,
        dtj.created_dt,
        dtj.updated_by,
        dtj.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_task_journal dtj
    JOIN tasker.st_markup_type smt
        ON ( smt.id = dtj.markup_type_id )
    JOIN tasker.dt_user du
        ON ( du.id = dtj.user_id )
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtj.task_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtj.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dtj.updated_by ) ;

ALTER TABLE dv_task_journal OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_journal IS 'Data view for task journal entries.' ;

REVOKE ALL ON TABLE dv_task_journal FROM public ;

GRANT SELECT ON table dv_task_journal TO tasker_owner ;

GRANT SELECT ON table dv_task_journal TO tasker_user ;
