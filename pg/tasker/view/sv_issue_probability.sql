CREATE OR REPLACE VIEW tasker.sv_issue_probability
AS
SELECT base.id,
        base.ranking_id,
        t002.name AS ranking,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_issue_probability base
    JOIN tasker_data.st_ranking t002
        ON ( t002.id = base.ranking_id ) ;

ALTER VIEW tasker.sv_issue_probability OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_issue_probability TO tasker_user ;

COMMENT ON VIEW tasker.sv_issue_probability IS 'View of: Reference table. Probability/repeatability of triggering an issue.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.id IS 'Unique ID/value for the probability.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.ranking_id IS 'The priority ranking associated with the probability.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.ranking IS 'The name for the ranking' ;
COMMENT ON COLUMN tasker.sv_issue_probability.name IS 'Display name for the probability.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.description IS 'Description of the probability.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_issue_probability.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
