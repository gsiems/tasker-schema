SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_activity_attribute_type
AS
SELECT aa.id AS attribute_type_id,
        aa.category_id AS activity_category_id,
        ac.name AS activity_category,
        aa.name AS attribute_name,
        aa.description AS attribute_description,
        aa.created_by,
        aa.created_dt,
        aa.updated_by,
        aa.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_activity_attribute_type aa
    JOIN tasker.rt_activity_category ac
        ON ( ac.id = aa.category_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = aa.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = aa.updated_by )
    ORDER BY aa.id ;

ALTER TABLE rv_activity_attribute_type OWNER TO tasker_owner ;

COMMENT ON VIEW rv_activity_attribute_type IS 'Reference view for types of activity attributes.' ;

REVOKE ALL ON table rv_activity_attribute_type FROM public ;

GRANT SELECT ON table rv_activity_attribute_type TO tasker_owner ;

GRANT SELECT ON table rv_activity_attribute_type TO tasker_user ;
