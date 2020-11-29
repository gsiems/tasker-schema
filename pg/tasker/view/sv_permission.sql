SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_permission
AS
SELECT id AS permission_id,
        name,
        description,
        can_create_task,
        can_update_task
    FROM tasker.st_permission
    ORDER BY id ;

ALTER TABLE sv_permission OWNER TO tasker_owner ;

COMMENT ON VIEW sv_permission IS 'System view for permissions.' ;

REVOKE ALL ON TABLE sv_permission FROM public ;

GRANT SELECT ON table sv_permission TO tasker_owner ;

GRANT SELECT ON table sv_permission TO tasker_user ;
