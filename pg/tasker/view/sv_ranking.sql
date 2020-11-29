SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_ranking
AS
SELECT id AS ranking_id,
        name
    FROM tasker.st_ranking
    ORDER BY id ;

ALTER TABLE sv_ranking OWNER TO tasker_owner ;

COMMENT ON VIEW sv_ranking IS 'System view for ranked parameters.' ;

REVOKE ALL ON TABLE sv_ranking FROM public ;

GRANT SELECT ON table sv_ranking TO tasker_owner ;

GRANT SELECT ON table sv_ranking TO tasker_user ;
