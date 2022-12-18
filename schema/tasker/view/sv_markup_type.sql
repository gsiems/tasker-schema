CREATE OR REPLACE VIEW tasker.sv_markup_type
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_markup_type base ;

ALTER VIEW tasker.sv_markup_type OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_markup_type TO tasker_user ;

COMMENT ON VIEW tasker.sv_markup_type IS 'View of: Reference table. Types of markup schemes that are supported.' ;
COMMENT ON COLUMN tasker.sv_markup_type.id IS 'Unique ID for a markup type.' ;
COMMENT ON COLUMN tasker.sv_markup_type.name IS 'Display name for the markup type.' ;
COMMENT ON COLUMN tasker.sv_markup_type.description IS 'Optional description for a markup type.' ;
COMMENT ON COLUMN tasker.sv_markup_type.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_markup_type.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
