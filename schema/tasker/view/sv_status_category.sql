CREATE OR REPLACE VIEW tasker.sv_status_category
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_status_category base ;

ALTER VIEW tasker.sv_status_category OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_status_category TO tasker_user ;

COMMENT ON VIEW tasker.sv_status_category IS 'View of: Reference table. Categories for the open statuses.' ;
COMMENT ON COLUMN tasker.sv_status_category.id IS 'Unique ID for an status category.' ;
COMMENT ON COLUMN tasker.sv_status_category.name IS 'The name for an status category.' ;
COMMENT ON COLUMN tasker.sv_status_category.description IS 'The description of an status category.' ;
COMMENT ON COLUMN tasker.sv_status_category.is_default IS 'Indicates whether or not the category is the default category.' ;
COMMENT ON COLUMN tasker.sv_status_category.is_enabled IS 'Indicates whether or not the category is available for new use.' ;
