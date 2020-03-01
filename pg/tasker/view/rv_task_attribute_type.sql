SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_task_attribute_type
AS
SELECT ta.id AS attribute_type_id,
        ta.category_id AS task_category_id,
        tc.name AS task_category,
        ta.name AS attribute_name,
        ta.description AS attribute_description,
        ta.created_by,
        ta.created_dt,
        ta.updated_by,
        ta.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_task_attribute_type ta
    JOIN tasker.st_task_category tc
        ON ( tc.id = ta.category_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = ta.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = ta.updated_by )
    ORDER BY ta.id ;

ALTER TABLE rv_task_attribute_type OWNER TO tasker_owner ;

COMMENT ON VIEW rv_task_attribute_type IS 'Reference view for types of task attributes.' ;

REVOKE ALL ON table rv_task_attribute_type FROM public ;

GRANT SELECT ON table rv_task_attribute_type TO tasker_owner ;

GRANT SELECT ON table rv_task_attribute_type TO tasker_user ;
