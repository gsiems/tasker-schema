CREATE OR REPLACE VIEW tasker.sv_role
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_activity_role,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_role base ;

ALTER VIEW tasker.sv_role OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_role TO tasker_user ;

COMMENT ON VIEW tasker.sv_role IS 'View of: Reference table. Roles that may be assigned to users.' ;
COMMENT ON COLUMN tasker.sv_role.id IS 'Unique ID for the role.' ;
COMMENT ON COLUMN tasker.sv_role.name IS 'The name for the role.' ;
COMMENT ON COLUMN tasker.sv_role.description IS 'The description of the role.' ;
COMMENT ON COLUMN tasker.sv_role.is_activity_role IS 'Indicates whether or not the role is for activities.' ;
COMMENT ON COLUMN tasker.sv_role.is_default IS 'Indicates whether or not the role is the default role.' ;
COMMENT ON COLUMN tasker.sv_role.is_enabled IS 'Indicates whether or not the role is available for new use.' ;
