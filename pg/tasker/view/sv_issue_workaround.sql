SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_issue_workaround
AS
SELECT id AS workaround_id,
        name
    FROM tasker.st_issue_workaround
    ORDER BY id ;

ALTER TABLE sv_issue_workaround OWNER TO tasker_owner ;

COMMENT ON VIEW sv_issue_workaround IS 'System view for workaround levels for issues.' ;

REVOKE ALL ON TABLE sv_issue_workaround FROM public ;

GRANT SELECT ON table sv_issue_workaround TO tasker_owner ;

GRANT SELECT ON table sv_issue_workaround TO tasker_user ;
