SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_activity
AS
SELECT da.ctid::text AS ctid,
        da.id AS activity_id,
        da.parent_id,
        toc.parents,
        toc.activity_depth,
        toc.activity_path,
        toc.activity_outln,
        da.activity_name,
        da.visibility_id,
        vis.name AS visibility,
        da.category_id,
        rac.name AS activity_category,
        da.status_id,
        CASE
            WHEN ts.open_status = 0 THEN true
            ELSE false
            END AS is_open,
        CASE
            WHEN ts.open_status = 2 THEN true
            ELSE false
            END AS is_closed,
        ts.name AS activity_status,
        da.priority_id,
        p.name AS activity_priority,
        da.markup_type_id,
        smt.name AS markup_type,
        da.description_markup,
        da.description_html,
        da.created_dt,
        da.created_by,
        da.updated_dt,
        da.updated_by,
        cu.username AS created_username,
        cu.full_name AS created_full_name,
        uu.username AS updated_username,
        uu.full_name AS updated_full_name
    FROM tasker.dt_activity da
    JOIN tasker.dv_activity_tree toc
        ON ( toc.activity_id = da.id )
    JOIN tasker.st_visibility vis
        ON ( vis.id = da.visibility_id )
    LEFT JOIN tasker.rt_activity_category rac
        ON ( rac.id = da.category_id )
    JOIN tasker.st_ranking p
        ON ( p.id = da.priority_id )
    JOIN tasker.rt_activity_category
        ON ( p.id = da.category_id )
    JOIN tasker.rt_activity_status ts
        ON ( ts.id = da.status_id )
    LEFT JOIN tasker.st_markup_type smt
        ON ( smt.id = da.markup_type_id )
    LEFT JOIN tasker.dt_user cu
        ON ( cu.id = da.created_by )
    LEFT JOIN tasker.dt_user uu
        ON ( uu.id = da.updated_by ) ;

ALTER TABLE dv_activity OWNER TO tasker_owner ;

COMMENT ON VIEW dv_activity IS 'Data view for activities.' ;

REVOKE ALL ON table dv_activity FROM public ;

GRANT SELECT ON table dv_activity TO tasker_owner ;

GRANT SELECT ON table dv_activity TO tasker_user ;
