SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_task_status
AS
SELECT ts.id AS task_status_id,
        ts.category_id AS task_category_id,
        tc.name AS task_category,
        ts.name,
        ts.description,
        ts.is_enabled,
        ts.open_status,
        CASE
            WHEN ts.open_status = 0 THEN true
            ELSE false
            END AS is_open,
        CASE
            WHEN ts.open_status = 2 THEN true
            ELSE false
            END AS is_closed,
        ts.created_by,
        ts.created_dt,
        ts.updated_by,
        ts.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_task_status ts
    JOIN tasker.st_task_category tc
        ON ( tc.id = ts.category_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = ts.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = ts.updated_by )
    ORDER BY ts.id ;

ALTER TABLE rv_task_status OWNER TO tasker_owner ;

COMMENT ON VIEW rv_task_status IS 'Reference view for task status.' ;

REVOKE ALL ON table rv_task_status FROM public ;

GRANT SELECT ON table rv_task_status TO tasker_owner ;

GRANT SELECT ON table rv_task_status TO tasker_user ;
