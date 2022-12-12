CREATE OR REPLACE VIEW tasker.sv_issue_severity
AS
SELECT base.id,
        base.ranking_id,
        t002.name AS ranking,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_issue_severity base
    JOIN tasker_data.st_ranking t002
        ON ( t002.id = base.ranking_id ) ;

ALTER VIEW tasker.sv_issue_severity OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_issue_severity TO tasker_user ;

COMMENT ON VIEW tasker.sv_issue_severity IS 'View of: Reference table. Indicates how bad/severe an issue is.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.id IS 'Unique ID/value for the severity.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.ranking_id IS 'The priority ranking associated with the severity.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.ranking IS 'The name for the ranking' ;
COMMENT ON COLUMN tasker.sv_issue_severity.name IS 'Display name for the severity.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.description IS 'Description of the severity.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_issue_severity.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
