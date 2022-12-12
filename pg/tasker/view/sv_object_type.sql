CREATE OR REPLACE VIEW tasker.sv_object_type
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_enabled
    FROM tasker_data.st_object_type base ;

ALTER VIEW tasker.sv_object_type OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_object_type TO tasker_user ;

COMMENT ON VIEW tasker.sv_object_type IS 'View of: Reference table. Objects (tasks, comments, journals) that can have assigned permissions.' ;
COMMENT ON COLUMN tasker.sv_object_type.id IS 'Unique ID for the object.' ;
COMMENT ON COLUMN tasker.sv_object_type.name IS 'The name of the object.' ;
COMMENT ON COLUMN tasker.sv_object_type.description IS 'The description of the object.' ;
COMMENT ON COLUMN tasker.sv_object_type.is_enabled IS 'Indicates whether or not the object is available for use.' ;
