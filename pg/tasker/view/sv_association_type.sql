CREATE OR REPLACE VIEW tasker.sv_association_type
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_association_type base ;

ALTER VIEW tasker.sv_association_type OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_association_type TO tasker_user ;

COMMENT ON VIEW tasker.sv_association_type IS 'View of: Reference table. Types of associations between tasks.' ;
COMMENT ON COLUMN tasker.sv_association_type.id IS 'Unique ID for a type of task association.' ;
COMMENT ON COLUMN tasker.sv_association_type.name IS 'The name for a type of task association.' ;
COMMENT ON COLUMN tasker.sv_association_type.description IS 'The description of a task association.' ;
COMMENT ON COLUMN tasker.sv_association_type.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_association_type.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
