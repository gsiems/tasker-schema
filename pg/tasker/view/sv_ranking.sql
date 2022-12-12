CREATE OR REPLACE VIEW tasker.sv_ranking
AS
SELECT base.id,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_ranking base ;

ALTER VIEW tasker.sv_ranking OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_ranking TO tasker_user ;

COMMENT ON VIEW tasker.sv_ranking IS 'View of: Reference table. Ranking values for attributes such as priority, severity, workarounds, etc.' ;
COMMENT ON COLUMN tasker.sv_ranking.id IS 'Unique ID/value for the ranking.' ;
COMMENT ON COLUMN tasker.sv_ranking.name IS 'Display name for the ranking.' ;
COMMENT ON COLUMN tasker.sv_ranking.description IS 'TBD' ;
COMMENT ON COLUMN tasker.sv_ranking.is_default IS 'Indicates whether or not the ranking is the default ranking.' ;
COMMENT ON COLUMN tasker.sv_ranking.is_enabled IS 'Indicates whether or not the ranking is available for new use.' ;
