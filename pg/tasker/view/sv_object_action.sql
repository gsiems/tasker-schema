CREATE OR REPLACE VIEW tasker.sv_object_action
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_object_action base ;

ALTER VIEW tasker.sv_object_action OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_object_action TO tasker_user ;

COMMENT ON VIEW tasker.sv_object_action IS 'View of: Reference table. Actions that may be performed on objects.' ;
COMMENT ON COLUMN tasker.sv_object_action.id IS 'Unique ID for an action.' ;
COMMENT ON COLUMN tasker.sv_object_action.name IS 'The name for an action.' ;
COMMENT ON COLUMN tasker.sv_object_action.description IS 'The description of an action.' ;
COMMENT ON COLUMN tasker.sv_object_action.is_default IS 'Indicates whether or not the action is the default action.' ;
COMMENT ON COLUMN tasker.sv_object_action.is_enabled IS 'Indicates whether or not the action is available for new use.' ;
