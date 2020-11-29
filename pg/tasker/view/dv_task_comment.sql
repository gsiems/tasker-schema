SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_comment
AS
SELECT dtc.id AS comment_id,
        dtc.parent_id,
        dtc.edition,
        toc.comment_depth,
        toc.comment_path,
        toc.comment_outln,
        dtc.task_id,
        dt.task_outln,
        dt.task_name,
        dtc.user_id,
        du.username,
        du.full_name,
        dtc.markup_type_id,
        smt.name AS markup_type,
        dtc.comment_markup,
        dtc.comment_html,
        dtc.created_dt,
        dtc.created_by,
        dtc.updated_dt,
        dtc.updated_by,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_task_comment dtc
    JOIN tasker.dv_task_comment_tree toc
        ON ( toc.comment_id = dtc.id )
    JOIN tasker.dt_user du
        ON ( du.id = dtc.user_id )
    JOIN tasker.dv_task dt
        ON ( dt.task_id = dtc.task_id )
    LEFT JOIN tasker.st_markup_type smt
        ON ( smt.id = dtc.markup_type_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dtc.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dtc.updated_by ) ;

ALTER TABLE dv_task_comment OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_comment IS 'Data view for task comments.' ;

REVOKE ALL ON TABLE dv_task_comment FROM public ;

GRANT SELECT ON table dv_task_comment TO tasker_owner ;

GRANT SELECT ON table dv_task_comment TO tasker_user ;
