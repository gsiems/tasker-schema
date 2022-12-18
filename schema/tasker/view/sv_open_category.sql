CREATE OR REPLACE VIEW tasker.sv_open_category
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_open_category base ;

ALTER VIEW tasker.sv_open_category OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_open_category TO tasker_user ;

COMMENT ON VIEW tasker.sv_open_category IS 'View of: Reference table. Categories for the open statuses.' ;
COMMENT ON COLUMN tasker.sv_open_category.id IS 'Unique ID for an open category.' ;
COMMENT ON COLUMN tasker.sv_open_category.name IS 'The name for an open category.' ;
COMMENT ON COLUMN tasker.sv_open_category.description IS 'The description of an open category.' ;
COMMENT ON COLUMN tasker.sv_open_category.is_default IS 'Indicates whether or not the category is the default category.' ;
COMMENT ON COLUMN tasker.sv_open_category.is_enabled IS 'Indicates whether or not the category is available for new use.' ;
