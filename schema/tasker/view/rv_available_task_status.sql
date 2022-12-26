CREATE OR REPLACE VIEW tasker.rv_available_task_status
AS
SELECT base.id,
        base.task_category_id,
        t002.name AS task_category,
        base.status_id,
        t003.name AS status,
        base.is_enabled,
        base.created_by_id,
        cu.username AS created_by,
        base.updated_by_id,
        uu.username AS updated_by,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.rt_available_task_status base
    JOIN tasker_data.st_task_category t002
        ON ( t002.id = base.task_category_id )
    JOIN tasker_data.rt_task_status t003
        ON ( t003.id = base.status_id )
    LEFT JOIN tasker_data.dt_user cu
        ON ( cu.id = base.created_by_id )
    LEFT JOIN tasker_data.dt_user uu
        ON ( uu.id = base.updated_by_id ) ;

ALTER VIEW tasker.rv_available_task_status OWNER TO tasker_owner ;

GRANT SELECT ON tasker.rv_available_task_status TO tasker_user ;

COMMENT ON VIEW tasker.rv_available_task_status IS 'View of: Reference table. Map task status values to specific task categories.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.id IS 'TBD' ;
COMMENT ON COLUMN tasker.rv_available_task_status.task_category_id IS 'The ID of the task category that the status is being mapped to.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.task_category IS 'The name for the task category' ;
COMMENT ON COLUMN tasker.rv_available_task_status.status_id IS 'The ID of the status.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.status IS 'The name of the status.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.is_enabled IS 'Indicates whether or not the category-status is available for use.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_available_task_status.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_available_task_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_available_task_status.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_available_task_status.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.rv_available_task_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;
