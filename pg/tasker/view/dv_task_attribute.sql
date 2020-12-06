SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_attribute
AS
SELECT dta.id AS task_attribute_id,
        dta.task_id,
        dta.attribute_type_id,
        reat.name AS attribute_type_name,
        dta.attribute_text,
        rtat.max_allowed,
        rtat.display_order,
        rtat.is_required,
        dta.created_by,
        dta.created_dt,
        dta.updated_by,
        dta.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_task_attribute dta
    INNER JOIN tasker.rt_task_attribute_type rtat
        ON ( rtat.id = dta.attribute_type_id )
    INNER JOIN tasker.rt_eav_attribute_type reat
        ON ( reat.id = rtat.eav_attribute_type_id )
    INNER JOIN tasker.st_eav_attribute_datatype sead
        ON ( reat.datatype_id = sead.id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dta.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dta.updated_by )
    ORDER BY rtat.display_order,
        reat.name ;

ALTER TABLE dv_task_attribute OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_attribute IS 'Data view for task attributes.' ;

REVOKE ALL ON TABLE dv_task_attribute FROM public ;

GRANT SELECT ON table dv_task_attribute TO tasker_owner ;

GRANT SELECT ON table dv_task_attribute TO tasker_user ;
