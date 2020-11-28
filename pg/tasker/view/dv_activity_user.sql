SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_activity_user
AS
SELECT dau.edition,
        dau.user_id,
        du.username,
        du.full_name,
        du.is_enabled AS user_is_enabled,
        du.email_address,
        du.email_is_enabled,
        dau.role_id,
        sr.name AS role_name,
        dau.activity_id,
        da.activity_depth,
        da.activity_outln,
        da.activity_name,
        CASE
            WHEN ts.open_status = 0 THEN true
            ELSE false
            END AS is_open,
        CASE
            WHEN ts.open_status = 2 THEN true
            ELSE false
            END AS is_closed,
        ts.name AS activity_status,
        dau.created_dt,
        dau.created_by,
        dau.updated_dt,
        dau.updated_by,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_activity_user dau
    JOIN tasker.dv_activity da
        ON ( da.activity_id = dau.activity_id )
    JOIN tasker.st_role sr
        ON ( sr.id = dau.role_id )
    JOIN tasker.dt_user du
        ON ( du.id = dau.user_id )
    JOIN tasker.rt_activity_status ts
        ON ( ts.id = da.status_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = dau.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = dau.updated_by ) ;

ALTER TABLE dv_activity_user OWNER TO tasker_owner ;

COMMENT ON VIEW dv_activity_user IS 'Data view for activity users.' ;

REVOKE ALL ON table dv_activity_user FROM public ;

GRANT SELECT ON table dv_activity_user TO tasker_owner ;

GRANT SELECT ON table dv_activity_user TO tasker_user ;
