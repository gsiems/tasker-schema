CREATE OR REPLACE VIEW tasker.sv_issue_workaround
AS
SELECT base.id,
        base.ranking_id,
        t002.name AS ranking,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_issue_workaround base
    JOIN tasker_data.st_ranking t002
        ON ( t002.id = base.ranking_id ) ;

ALTER VIEW tasker.sv_issue_workaround OWNER TO tasker_owner ;

GRANT SELECT ON tasker.sv_issue_workaround TO tasker_user ;

COMMENT ON VIEW tasker.sv_issue_workaround IS 'View of: Reference table. The type of workarounds available for an issue.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.id IS 'Unique ID/value for the workaround.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.ranking_id IS 'The priority ranking associated with the workaround.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.ranking IS 'The name for the ranking' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.name IS 'Display name for the workaround.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.description IS 'Description of the workaround.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_issue_workaround.is_enabled IS 'Indicates whether or not the row is available for new use.' ;
