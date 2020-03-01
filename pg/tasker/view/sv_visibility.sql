SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_visibility
AS
SELECT id AS visibility_id,
        name,
        description
    FROM tasker.st_visibility
    ORDER BY id ;

ALTER TABLE sv_visibility OWNER TO tasker_owner ;

COMMENT ON VIEW sv_visibility IS 'System view for visibilities.' ;

REVOKE ALL ON table sv_visibility FROM public ;

GRANT SELECT ON table sv_visibility TO tasker_owner ;

GRANT SELECT ON table sv_visibility TO tasker_user ;
