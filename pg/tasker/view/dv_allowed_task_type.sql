SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_allowed_task_type
AS
SELECT datt.ctid,
        datt.activity_id,
        datt.task_type_id,
        rtt.category_id AS task_category_id,
        tc.name AS task_category,
        rtt.name,
        rtt.description,
        datt.created_dt,
        datt.created_by,
        cu.username AS created_username,
        cu.full_name AS created_full_name
    FROM tasker.dt_allowed_task_type datt
    JOIN tasker.rt_task_type rtt
        ON ( rtt.id = datt.task_type_id )
    JOIN tasker.st_task_category tc
        ON ( tc.id = rtt.category_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = datt.created_by ) ;

ALTER TABLE dv_allowed_task_type OWNER TO tasker_owner ;

COMMENT ON VIEW dv_allowed_task_type IS 'Data view for allowed tasks.' ;

REVOKE ALL ON table dv_allowed_task_type FROM public ;

GRANT SELECT ON table dv_allowed_task_type TO tasker_owner ;

GRANT SELECT ON table dv_allowed_task_type TO tasker_user ;
