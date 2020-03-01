SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_issue_probability
AS
SELECT id AS probability_id,
        name
    FROM tasker.st_issue_probability
    ORDER BY id ;

ALTER TABLE sv_issue_probability OWNER TO tasker_owner ;

COMMENT ON VIEW sv_issue_probability IS 'System view for probability/repeatability of triggering an issue.' ;

REVOKE ALL ON table sv_issue_probability FROM public ;

GRANT SELECT ON table sv_issue_probability TO tasker_owner ;

GRANT SELECT ON table sv_issue_probability TO tasker_user ;
