SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_role
AS
SELECT id AS role_id,
        name,
        description,
        is_activity_owner,
        can_create_task,
        can_update_task
    FROM tasker.st_role
    ORDER BY id ;

ALTER TABLE sv_role OWNER TO tasker_owner ;

COMMENT ON VIEW sv_role IS 'System view for roles.' ;

REVOKE ALL ON table sv_role FROM public ;

GRANT SELECT ON table sv_role TO tasker_owner ;

GRANT SELECT ON table sv_role TO tasker_user ;
