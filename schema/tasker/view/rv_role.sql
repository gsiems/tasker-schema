SET search_path = tasker, pg_catalog ;

CREATE VIEW rv_role
AS
SELECT rtt.id AS role_id,
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
    FROM tasker.rt_role rtt
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = rtt.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = rtt.updated_by )
    ORDER BY rtt.id ;

ALTER TABLE rv_role OWNER TO tasker_owner ;

COMMENT ON VIEW rv_role IS 'Reference view for roles.' ;

REVOKE ALL ON table rv_role FROM public ;

GRANT SELECT ON table rv_role TO tasker_owner ;

GRANT SELECT ON table rv_role TO tasker_user ;
