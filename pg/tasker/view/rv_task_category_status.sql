CREATE OR REPLACE VIEW tasker.rv_task_category_status
AS
SELECT base.id,
        base.category_id,
        t002.name AS category,
        base.status_id,
        base.is_enabled,
        base.created_by_id,
        cu.username AS created_by,
        base.updated_by_id,
        uu.username AS updated_by,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.rt_task_category_status base
    JOIN tasker_data.st_task_category t002
        ON ( t002.id = base.category_id )
    LEFT JOIN tasker_data.dt_user cu
        ON ( cu.id = base.created_by_id )
    LEFT JOIN tasker_data.dt_user uu
        ON ( uu.id = base.updated_by_id ) ;

ALTER VIEW tasker.rv_task_category_status OWNER TO tasker_owner ;

GRANT SELECT ON tasker.rv_task_category_status TO tasker_user ;

COMMENT ON VIEW tasker.rv_task_category_status IS 'View of: Reference table. Map task status values to task categories.' ;
COMMENT ON COLUMN tasker.rv_task_category_status.id IS 'TBD' ;
COMMENT ON COLUMN tasker.rv_task_category_status.category_id IS 'The category of task that the status is for.' ;
COMMENT ON COLUMN tasker.rv_task_category_status.category IS 'The name for the category' ;
COMMENT ON COLUMN tasker.rv_task_category_status.status_id IS 'The status.' ;
COMMENT ON COLUMN tasker.rv_task_category_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;
COMMENT ON COLUMN tasker.rv_task_category_status.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_category_status.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_category_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_category_status.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_category_status.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.rv_task_category_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;
