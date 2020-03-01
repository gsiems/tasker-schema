SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_issue_severity
AS
SELECT id AS severity_id,
        name
    FROM tasker.st_issue_severity
    ORDER BY id ;

ALTER TABLE sv_issue_severity OWNER TO tasker_owner ;

COMMENT ON VIEW sv_issue_severity IS 'System view for severity levels for issues.' ;

REVOKE ALL ON table sv_issue_severity FROM public ;

GRANT SELECT ON table sv_issue_severity TO tasker_owner ;

GRANT SELECT ON table sv_issue_severity TO tasker_user ;
