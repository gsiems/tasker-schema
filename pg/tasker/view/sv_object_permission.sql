CREATE OR REPLACE VIEW tasker.sv_object_permission
AS
SELECT base.object_type_id,
        t001.name AS object_type,
        base.action_id,
        t002.name AS action,
        base.minimum_role_id,
        t003.name AS minimum_role,
        base.is_enabled
    FROM tasker_data.st_object_permission base
    JOIN tasker_data.st_object_type t001
        ON ( t001.id = base.object_type_id )
    JOIN tasker_data.st_object_action t002
        ON ( t002.id = base.action_id )
    JOIN tasker_data.st_role t003
        ON ( t003.id = base.minimum_role_id ) ;

ALTER VIEW tasker.sv_object_permission OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_object_permission TO tasker_user ;

COMMENT ON VIEW tasker.sv_object_permission IS 'View of: Reference table. Permitted actions for objects.' ;
COMMENT ON COLUMN tasker.sv_object_permission.object_type_id IS 'The object type that the permission is for.' ;
COMMENT ON COLUMN tasker.sv_object_permission.object_type IS 'The name for the object type' ;
COMMENT ON COLUMN tasker.sv_object_permission.action_id IS 'The action to permit.' ;
COMMENT ON COLUMN tasker.sv_object_permission.action IS 'The name for the action' ;
COMMENT ON COLUMN tasker.sv_object_permission.minimum_role_id IS 'The minimum role required to perform the action.' ;
COMMENT ON COLUMN tasker.sv_object_permission.minimum_role IS 'The name for the minimum role' ;
COMMENT ON COLUMN tasker.sv_object_permission.is_enabled IS 'Indicates whether or not the role permission is enabled.' ;
