SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_markup_type
AS
SELECT id AS markup_type_id,
        name,
        description,
        is_enabled
    FROM tasker.st_markup_type
    ORDER BY id ;

ALTER TABLE sv_markup_type OWNER TO tasker_owner ;

COMMENT ON VIEW sv_markup_type IS 'System view for supported markup types.' ;

REVOKE ALL ON TABLE sv_markup_type FROM public ;

GRANT SELECT ON table sv_markup_type TO tasker_owner ;

GRANT SELECT ON table sv_markup_type TO tasker_user ;
