SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task
AS
SELECT dt.edition,
        dt.id AS task_id,
        dt.activity_id,
        dt.parent_id,
        toc.parents,
        toc.task_depth,
        toc.task_path,
        toc.task_outln,
        dt.task_name,
        rtt.category_id AS task_category_id,
        tc.name AS task_category,
        dt.task_type_id,
        rtt.name AS task_type,
        dt.status_id,
        CASE
            WHEN ts.open_status = 0 THEN true
            ELSE false
            END AS is_open,
        CASE
            WHEN ts.open_status = 2 THEN true
            ELSE false
            END AS is_closed,
        ts.name AS task_status,
        dt.priority_id,
        p.name AS task_priority,
        dt.markup_type_id,
        smt.name AS markup_type,
        dt.actual_start,
        dt.actual_end,
        dt.time_estimate,
        dt.description_markup,
        dt.description_html,
        dt.created_dt,
        dt.created_by,
        dt.updated_dt,
        dt.updated_by,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_task dt
    JOIN tasker.dv_task_tree toc
        ON ( toc.task_id = dt.id )
    JOIN tasker.dt_task_regular dtr
        ON ( dtr.task_id = dt.id )
    JOIN tasker.rt_task_type rtt
        ON ( rtt.id = dt.task_type_id )
    JOIN tasker.st_task_category tc
        ON ( tc.id = rtt.category_id )
    LEFT JOIN tasker.st_ranking p
        ON ( p.id = dt.priority_id )
    LEFT JOIN tasker.rt_task_status ts
        ON ( ts.id = dt.status_id )
    LEFT JOIN tasker.st_markup_type smt
        ON ( smt.id = dt.markup_type_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dt.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dt.updated_by ) ;

ALTER TABLE dv_task OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task IS 'Data view for all tasks.' ;

REVOKE ALL ON table dv_task FROM public ;

GRANT SELECT ON table dv_task TO tasker_owner ;

GRANT SELECT ON table dv_task TO tasker_user ;
