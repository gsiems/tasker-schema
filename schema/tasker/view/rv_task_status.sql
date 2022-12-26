CREATE OR REPLACE VIEW tasker.rv_task_status
AS
SELECT base.id,
        base.name,
        base.status_category_id,
        t002.name AS status_category,
        t002.name || ': ' || base.name AS full_label,
        base.description,
        base.is_default,
        base.is_enabled,
        base.created_by_id,
        cu.username AS created_by,
        base.updated_by_id,
        uu.username AS updated_by,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.rt_task_status base
    JOIN tasker_data.st_status_category t002
        ON ( t002.id = base.status_category_id )
    LEFT JOIN tasker_data.dt_user cu
        ON ( cu.id = base.created_by_id )
    LEFT JOIN tasker_data.dt_user uu
        ON ( uu.id = base.updated_by_id ) ;

ALTER VIEW tasker.rv_task_status OWNER TO tasker_owner ;

GRANT SELECT ON tasker.rv_task_status TO tasker_user ;

COMMENT ON VIEW tasker.rv_task_status IS 'View of: Reference table. Statuses for tasks.' ;
COMMENT ON COLUMN tasker.rv_task_status.id IS 'Unique ID for the status' ;
COMMENT ON COLUMN tasker.rv_task_status.name IS 'The name of the status.' ;
COMMENT ON COLUMN tasker.rv_task_status.status_category_id IS 'The ID of the status category indicating if the status is open, closed, or not open.' ;
COMMENT ON COLUMN tasker.rv_task_status.status_category IS 'The name for the status category' ;
COMMENT ON COLUMN tasker.rv_task_status.description IS 'The description of the status.' ;
COMMENT ON COLUMN tasker.rv_task_status.is_default IS 'Indicates whether or not the row is the default row.' ;
COMMENT ON COLUMN tasker.rv_task_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;
COMMENT ON COLUMN tasker.rv_task_status.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_status.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_status.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.rv_task_status.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.rv_task_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;
