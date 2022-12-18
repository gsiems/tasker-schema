CREATE OR REPLACE VIEW tasker.sv_task_category
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_task_category base ;

ALTER VIEW tasker.sv_task_category OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_task_category TO tasker_user ;

COMMENT ON VIEW tasker.sv_task_category IS 'View of: Reference table. Broad categories that tasks fall into.' ;
COMMENT ON COLUMN tasker.sv_task_category.id IS 'Unique ID for a task category.' ;
COMMENT ON COLUMN tasker.sv_task_category.name IS 'The name for a task category.' ;
COMMENT ON COLUMN tasker.sv_task_category.description IS 'The description of a task category.' ;
COMMENT ON COLUMN tasker.sv_task_category.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_task_category.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
