SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_task_attribute_type
AS
SELECT rtat.id AS attribute_type_id,
        rtat.category_id,
        stc.name AS task_category,
        rtat.task_type_id,
        rtt.name AS task_type_name,
        reat.name AS attribute_type_name,
        reat.description AS attribute_type_description,
        sead.name AS datatype,
        rtat.eav_attribute_type_id,
        rtat.max_allowed,
        rtat.display_order,
        rtat.is_required,
        rtat.is_enabled,
        rtat.created_by,
        rtat.created_dt,
        rtat.updated_by,
        rtat.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_task_attribute_type rtat
    INNER JOIN tasker.rt_eav_attribute_type reat
        ON ( reat.id = rtat.eav_attribute_type_id )
    INNER JOIN tasker.st_eav_attribute_datatype sead
        ON ( reat.datatype_id = sead.id )
    INNER JOIN tasker.st_task_category stc
        ON ( rtat.category_id = stc.id )
    LEFT JOIN tasker.rt_task_type rtt
        ON ( rtat.task_type_id = rtt.id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = rtat.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = rtat.updated_by ) ;

ALTER TABLE rv_task_attribute_type OWNER TO tasker_owner ;

COMMENT ON VIEW rv_task_attribute_type IS 'Reference view for types of task attributes.' ;

REVOKE ALL ON table rv_task_attribute_type FROM public ;

GRANT SELECT ON table rv_task_attribute_type TO tasker_owner ;

GRANT SELECT ON table rv_task_attribute_type TO tasker_user ;
