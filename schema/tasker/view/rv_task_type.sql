CREATE OR REPLACE VIEW tasker.rv_task_type
AS
SELECT base.id,
        base.task_category_id,
        t002.name AS task_category,
        base.markup_type_id,
        t003.name AS markup_type,
        t002.name || ': ' || base.name AS full_label,
        base.name,
        base.description,
        base.template_markup,
        base.template_html,
        base.is_default,
        base.is_enabled,
        base.created_by_id,
        cu.username AS created_by,
        base.updated_by_id,
        uu.username AS updated_by,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.rt_task_type base
    JOIN tasker_data.st_task_category t002
        ON ( t002.id = base.task_category_id )
    JOIN tasker_data.st_markup_type t003
        ON ( t003.id = base.markup_type_id )
    LEFT JOIN tasker_data.dt_user cu
        ON ( cu.id = base.created_by_id )
    LEFT JOIN tasker_data.dt_user uu
        ON ( uu.id = base.updated_by_id ) ;

ALTER VIEW tasker.rv_task_type OWNER TO tasker_owner ;

GRANT SELECT ON tasker.rv_task_type TO tasker_user ;

COMMENT ON VIEW tasker.rv_task_type IS 'View of: Reference table. Types of tasks.' ;
COMMENT ON COLUMN tasker.rv_task_type.id IS 'Unique ID for a task type' ;
COMMENT ON COLUMN tasker.rv_task_type.task_category_id IS 'The category that the task type belongs to.' ;
COMMENT ON COLUMN tasker.rv_task_type.task_category IS 'The name for the category' ;
COMMENT ON COLUMN tasker.rv_task_type.markup_type_id IS 'The ID of the markup format used for the template_markup column.' ;
COMMENT ON COLUMN tasker.rv_task_type.markup_type IS 'The name for the markup type' ;
COMMENT ON COLUMN tasker.rv_task_type.name IS 'The name for a task type.' ;
COMMENT ON COLUMN tasker.rv_task_type.description IS 'The description of a task type.' ;
COMMENT ON COLUMN tasker.rv_task_type.template_markup IS 'The optional template to use when creating a new task.' ;
COMMENT ON COLUMN tasker.rv_task_type.template_html IS 'The template in HTML format.' ;
COMMENT ON COLUMN tasker.rv_task_type.is_default IS 'TBD' ;
COMMENT ON COLUMN tasker.rv_task_type.is_enabled IS 'Indicates whether or not the task type is available for use.' ;
COMMENT ON COLUMN tasker.rv_task_type.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_type.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_type.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_type.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_type.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.rv_task_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;
