SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_activity_category
AS
SELECT rtt.id AS category_id,
        rtt.name,
        rtt.description,
        rtt.is_enabled,
        rtt.created_by,
        rtt.created_dt,
        rtt.updated_by,
        rtt.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.rt_activity_category rtt
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = rtt.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = rtt.updated_by )
    ORDER BY rtt.id ;

ALTER TABLE rv_activity_category OWNER TO tasker_owner ;

COMMENT ON VIEW rv_activity_category IS 'Reference view for activity categories.' ;

REVOKE ALL ON table rv_activity_category FROM public ;

GRANT SELECT ON table rv_activity_category TO tasker_owner ;

GRANT SELECT ON table rv_activity_category TO tasker_user ;
