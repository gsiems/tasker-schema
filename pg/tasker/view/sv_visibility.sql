CREATE OR REPLACE VIEW tasker.sv_visibility
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_visibility base ;

ALTER VIEW tasker.sv_visibility OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_visibility TO tasker_user ;

COMMENT ON VIEW tasker.sv_visibility IS 'View of: System reference table. Visibility levels for activities.' ;
COMMENT ON COLUMN tasker.sv_visibility.id IS 'Unique ID for a visibility level.' ;
COMMENT ON COLUMN tasker.sv_visibility.name IS 'The name for the visibility level.' ;
COMMENT ON COLUMN tasker.sv_visibility.description IS 'The description of the visibility level.' ;
COMMENT ON COLUMN tasker.sv_visibility.is_default IS 'Indicates whether or not the visibility level is the default visibility level.' ;
COMMENT ON COLUMN tasker.sv_visibility.is_enabled IS 'Indicates whether or not the visibility level is available for new use.' ;
