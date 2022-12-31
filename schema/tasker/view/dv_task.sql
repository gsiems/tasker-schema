CREATE OR REPLACE VIEW tasker.dv_task
AS
SELECT base.id,
        base.parent_id,
        tree.parents,
        tree.task_depth,
        tree.task_path,
        tree.outline_label,
        base.edition,
        base.activity_id,
        base.task_name,
        base.owner_id,
        t006.username AS owner,
        base.assignee_id,
        t007.username AS assignee,
        base.task_type_id,
        t008.name AS task_type,
        t008.task_category_id,
        t008a.name AS task_category,
        base.time_estimate,
        base.visibility_id,
        t010.name AS visibility,
        base.markup_type_id,
        t011.name AS markup_type,
        base.status_id,
        t012.name AS status,
        t012.status_category_id,
        t012.status_category,
        base.priority_id,
        t013.name AS priority,
        base.desired_start_importance_id,
        t014.name AS desired_start_importance,
        base.desired_end_importance_id,
        t015.name AS desired_end_importance,
        base.desired_start,
        base.desired_end,
        base.estimated_start,
        base.estimated_end,
        base.actual_start,
        base.actual_end,
        base.description_markup,
        base.description_html,
        base.created_by_id,
        cu.username AS created_by,
        base.updated_by_id,
        uu.username AS updated_by,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.dt_task base
    LEFT JOIN tasker.dv_task_tree tree
        ON ( tree.id = base.id )
    LEFT JOIN tasker_data.dt_user t006
        ON ( t006.id = base.owner_id )
    LEFT JOIN tasker_data.dt_user t007
        ON ( t007.id = base.assignee_id )
    JOIN tasker_data.rt_task_type t008
        ON ( t008.id = base.task_type_id )
    JOIN tasker_data.st_task_category t008a
        ON ( t008a.id = t008.task_category_id )
    JOIN tasker_data.st_visibility t010
        ON ( t010.id = base.visibility_id )
    JOIN tasker_data.st_markup_type t011
        ON ( t011.id = base.markup_type_id )
    LEFT JOIN tasker.rv_task_status t012
        ON ( t012.id = base.status_id )
    LEFT JOIN tasker_data.st_ranking t013
        ON ( t013.id = base.priority_id )
    LEFT JOIN tasker_data.st_date_importance t014
        ON ( t014.id = base.desired_start_importance_id )
    LEFT JOIN tasker_data.st_date_importance t015
        ON ( t015.id = base.desired_end_importance_id )
    LEFT JOIN tasker_data.dt_user cu
        ON ( cu.id = base.created_by_id )
    LEFT JOIN tasker_data.dt_user uu
        ON ( uu.id = base.updated_by_id ) ;

ALTER VIEW tasker.dv_task OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_task TO tasker_user ;

COMMENT ON VIEW tasker.dv_task IS 'View of: Tasks.' ;
COMMENT ON COLUMN tasker.dv_task.id IS 'The unique ID for the task.' ;
COMMENT ON COLUMN tasker.dv_task.parent_id IS 'The ID of the parent task (if any).' ;
COMMENT ON COLUMN tasker.dv_task.parents IS 'The array of parent task IDs.' ;
COMMENT ON COLUMN tasker.dv_task.task_depth IS 'Indicates how far the task is from the tree root' ;
COMMENT ON COLUMN tasker.dv_task.task_path IS 'The array of node indexes in the tree (mostly for sorting purposes)' ;
COMMENT ON COLUMN tasker.dv_task.outline_label IS 'The (decimal dotted notation) label for the task hierarchy outline.' ;
COMMENT ON COLUMN tasker.dv_task.edition IS 'Indicates the number of edits made to the task. Intended for use in determining if a task has been edited between select and update.' ;
COMMENT ON COLUMN tasker.dv_task.activity_id IS 'The ID of the activity that the task belongs to. For tasks that are activities, the activity ID equals the task ID.' ;
COMMENT ON COLUMN tasker.dv_task.task_name IS 'The name for the task.' ;
COMMENT ON COLUMN tasker.dv_task.owner_id IS 'The ID of the user that owns the task.' ;
COMMENT ON COLUMN tasker.dv_task.owner IS 'The username for the owner' ;
COMMENT ON COLUMN tasker.dv_task.assignee_id IS 'The ID of the user that the task is assigned to.' ;
COMMENT ON COLUMN tasker.dv_task.assignee IS 'The username for the assignee' ;
COMMENT ON COLUMN tasker.dv_task.task_type_id IS 'The ID of the task type.' ;
COMMENT ON COLUMN tasker.dv_task.task_type IS 'The name for the task type' ;
COMMENT ON COLUMN tasker.dv_task.task_category_id IS 'The ID of the task category.' ;
COMMENT ON COLUMN tasker.dv_task.task_category IS 'The name for the category' ;
COMMENT ON COLUMN tasker.dv_task.time_estimate IS 'The estimated time that it should take to implement the task in minutes.' ;
COMMENT ON COLUMN tasker.dv_task.visibility_id IS 'Indicates the visibility of the task.' ;
COMMENT ON COLUMN tasker.dv_task.visibility IS 'The name for the visibility' ;
COMMENT ON COLUMN tasker.dv_task.markup_type_id IS 'The ID of the markup format used for the description_markup column.' ;
COMMENT ON COLUMN tasker.dv_task.markup_type IS 'The name for the markup type' ;
COMMENT ON COLUMN tasker.dv_task.status_id IS 'The status of the task.' ;
COMMENT ON COLUMN tasker.dv_task.status IS 'The name of the status.' ;
COMMENT ON COLUMN tasker.dv_task.status_category_id IS 'The ID of the category indicating if the status is open, closed, or not open.' ;
COMMENT ON COLUMN tasker.dv_task.status_category IS 'The name for the status category' ;
COMMENT ON COLUMN tasker.dv_task.priority_id IS 'The priority of the task.' ;
COMMENT ON COLUMN tasker.dv_task.priority IS 'The name for the priority' ;
COMMENT ON COLUMN tasker.dv_task.desired_start_importance_id IS 'The importance of not making the desired start date.' ;
COMMENT ON COLUMN tasker.dv_task.desired_start_importance IS 'The name for the desired start importance' ;
COMMENT ON COLUMN tasker.dv_task.desired_end_importance_id IS 'The importance of not making the desired end date.' ;
COMMENT ON COLUMN tasker.dv_task.desired_end_importance IS 'The name for the desired end importance' ;
COMMENT ON COLUMN tasker.dv_task.desired_start IS 'The desired date (if any) that work on the task should start.' ;
COMMENT ON COLUMN tasker.dv_task.desired_end IS 'The desired date (if any) for the completion for the task.' ;
COMMENT ON COLUMN tasker.dv_task.estimated_start IS 'The estimated date (if any) that work on the task should start.' ;
COMMENT ON COLUMN tasker.dv_task.estimated_end IS 'The estimated date (if any) for the completion for the task.' ;
COMMENT ON COLUMN tasker.dv_task.actual_start IS 'The actual date that work on the task was started.' ;
COMMENT ON COLUMN tasker.dv_task.actual_end IS 'The actual date that the task was finished.' ;
COMMENT ON COLUMN tasker.dv_task.description_markup IS 'A description of the task and/or the purpose of the task.' ;
COMMENT ON COLUMN tasker.dv_task.description_html IS 'The description in HTML format.' ;
COMMENT ON COLUMN tasker.dv_task.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_task.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_task.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_task.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_task.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.dv_task.updated_dt IS 'The timestamp when the row was most recently updated.' ;
