SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_user
AS
SELECT du.ctid::text AS ctid,
        du.id AS user_id,
        du.reports_to,
        cc.bosses,
        cc.user_depth,
        cc.user_outln,
        rpts2.username AS reports_to_username,
        rpts2.full_name AS reports_to_full_name,
        du.username,
        du.full_name,
        du.email_address,
        du.email_is_enabled,
        du.is_enabled,
        du.is_admin,
        du.last_login,
        du.created_by,
        du.created_dt,
        du.updated_by,
        du.updated_dt,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_user du
    LEFT JOIN tasker.dv_user_cc cc
        ON ( cc.user_id = du.id )
    LEFT JOIN tasker.dt_user rpts2
        ON ( rpts2.id = du.reports_to )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = du.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = du.updated_by ) ;

ALTER TABLE dv_user OWNER TO tasker_owner ;

COMMENT ON VIEW dv_user IS 'Data view for users.' ;

REVOKE ALL ON table dv_user FROM public ;

GRANT SELECT ON table dv_user TO tasker_owner ;

GRANT SELECT ON table dv_user TO tasker_user ;
