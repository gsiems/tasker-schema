SET search_path = tasker, pg_catalog ;

CREATE VIEW sv_task_category
AS
SELECT id AS task_category_id,
        name,
        description
    FROM tasker.st_task_category
    ORDER BY id ;

ALTER TABLE sv_task_category OWNER TO tasker_owner ;

COMMENT ON VIEW sv_task_category IS 'System view for task categories.' ;

REVOKE ALL ON table sv_task_category FROM public ;

GRANT SELECT ON table sv_task_category TO tasker_owner ;

GRANT SELECT ON table sv_task_category TO tasker_user ;
