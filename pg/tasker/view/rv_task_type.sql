SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_task_type
AS
SELECT rtt.id AS task_type_id,
        rtt.category_id AS task_category_id,
        tc.name AS task_category,
        rtt.name,
        rtt.description,
        rtt.markup_type_id AS template_markup_type_id,
        smt.name AS template_markup_type,
        rtt.template_markup,
        rtt.template_html,
        rtt.is_enabled,
        rtt.created_by,
        rtt.created_dt,
        rtt.updated_by,
        rtt.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_task_type rtt
    JOIN tasker.st_task_category tc
        ON ( tc.id = rtt.category_id )
    LEFT JOIN tasker.st_markup_type smt
        ON ( smt.id = rtt.markup_type_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = rtt.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = rtt.updated_by )
    ORDER BY rtt.id ;

ALTER TABLE rv_task_type OWNER TO tasker_owner ;

COMMENT ON VIEW rv_task_type IS 'Reference view for task types.' ;

REVOKE ALL ON table rv_task_type FROM public ;

GRANT SELECT ON table rv_task_type TO tasker_owner ;

GRANT SELECT ON table rv_task_type TO tasker_user ;
