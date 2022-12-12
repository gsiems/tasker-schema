CREATE OR REPLACE VIEW tasker.sv_date_importance
AS
SELECT base.id,
        base.ranking_id,
        t002.name AS ranking,
        base.name,
        base.description,
        base.is_default,
        base.is_enabled
    FROM tasker_data.st_date_importance base
    JOIN tasker_data.st_ranking t002
        ON ( t002.id = base.ranking_id ) ;


ALTER VIEW tasker.sv_date_importance OWNER TO tasker_owner ;

GRANT SELECT ON VIEW tasker.sv_date_importance TO tasker_user ;

COMMENT ON VIEW tasker.sv_date_importance IS 'View of: Reference table. For estimated dates. Indicates how important it is for a date to be met.' ;
COMMENT ON COLUMN tasker.sv_date_importance.id IS 'Unique ID/value for the severity level.' ;
COMMENT ON COLUMN tasker.sv_date_importance.ranking_id IS 'The priority ranking associated with the date severity.' ;
COMMENT ON COLUMN tasker.sv_date_importance.ranking IS 'The name for the ranking' ;
COMMENT ON COLUMN tasker.sv_date_importance.name IS 'Display name for the date severity level.' ;
COMMENT ON COLUMN tasker.sv_date_importance.description IS 'Description of the date severity level.' ;
COMMENT ON COLUMN tasker.sv_date_importance.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.sv_date_importance.is_enabled IS 'Indicates whether or not the row is available for new use.' ;


