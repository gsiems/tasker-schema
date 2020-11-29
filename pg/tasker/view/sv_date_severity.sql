SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_date_severity
AS
SELECT id AS date_severity_id,
        name
    FROM tasker.st_date_severity
    ORDER BY id ;

ALTER TABLE sv_date_severity OWNER TO tasker_owner ;

COMMENT ON VIEW sv_date_severity IS 'System view for date severities.' ;

REVOKE ALL ON TABLE sv_date_severity FROM public ;

GRANT SELECT ON table sv_date_severity TO tasker_owner ;

GRANT SELECT ON table sv_date_severity TO tasker_user ;
