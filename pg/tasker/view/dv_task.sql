SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task
AS
SELECT dt.id AS task_id,
        dt.activity_id,
        dt.parent_id,
        dt.edition,
        toc.parents,
        toc.task_depth,
        toc.task_path,
        toc.task_outln,
        dt.task_name,
        dt.visibility_id,
        sv.name AS visbility,
        dt.owner_id,
        ou.username AS owner_username,
        ou.full_name AS owner_full_name,
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
        dt.desired_start_severity_id,
        sds.name AS desired_start_severity,
        dt.desired_end_severity_id,
        eds.name AS desired_end_severity,
        dt.desired_start,
        dt.desired_end,
        dt.estimated_start,
        dt.estimated_end,
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
    JOIN tasker.rt_task_type rtt
        ON ( rtt.id = dt.task_type_id )
    JOIN tasker.st_task_category tc
        ON ( tc.id = rtt.category_id )
    JOIN tasker.st_visibility sv
        ON ( sv.id = dt.visibility_id )
    JOIN tasker.dt_user ou
        ON ( ou.id = dt.created_by )
    LEFT JOIN tasker.st_date_severity sds
        ON ( dt.desired_start_severity_id = sds.id )
    LEFT JOIN tasker.st_date_severity eds
        ON ( dt.desired_start_severity_id = eds.id )
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

REVOKE ALL ON TABLE dv_task FROM public ;

GRANT SELECT ON table dv_task TO tasker_owner ;

GRANT SELECT ON table dv_task TO tasker_user ;
