CREATE OR REPLACE VIEW tasker.dv_activity
AS
SELECT base.id,
        base.parent_id,
        tree.parents,
        tree.activity_depth,
        tree.activity_path,
        tree.outline_label,
        base.edition,
        base.task_name AS activity_name,
        base.owner_id,
        t006.username AS owner,
        base.task_type_id AS activity_type_id,
        t008.name AS activity_type,
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
    JOIN tasker.dv_activity_tree tree
        ON ( tree.id = base.id )
    LEFT JOIN tasker_data.dt_user t006
        ON ( t006.id = base.owner_id )
    JOIN tasker_data.rt_task_type t008
        ON ( t008.id = base.task_type_id )
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
        ON ( uu.id = base.updated_by_id )
    WHERE base.id = base.activity_id ;

ALTER VIEW tasker.dv_activity OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_activity TO tasker_user ;

COMMENT ON VIEW tasker.dv_activity IS 'View of: activities.' ;
COMMENT ON COLUMN tasker.dv_activity.id IS 'The unique ID for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.parent_id IS 'The ID of the parent activity (if any).' ;
COMMENT ON COLUMN tasker.dv_activity.parents IS 'The array of parent activity IDs.' ;
COMMENT ON COLUMN tasker.dv_activity.activity_depth IS 'Indicates how far the activity is from the tree root' ;
COMMENT ON COLUMN tasker.dv_activity.activity_path IS 'The array of node indexes in the tree (mostly for sorting purposes)' ;
COMMENT ON COLUMN tasker.dv_activity.outline_label IS 'The (decimal dotted notation) label for the activity hierarchy outline.' ;
COMMENT ON COLUMN tasker.dv_activity.edition IS 'Indicates the number of edits made to the activity. Intended for use in determining if an activity has been edited between select and update.' ;
COMMENT ON COLUMN tasker.dv_activity.activity_name IS 'The name for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.owner_id IS 'The ID of the user that owns the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.owner IS 'The username for the owner' ;
COMMENT ON COLUMN tasker.dv_activity.activity_type_id IS 'The ID of the activity type.' ;
COMMENT ON COLUMN tasker.dv_activity.activity_type IS 'The name for the activity type' ;
COMMENT ON COLUMN tasker.dv_activity.visibility_id IS 'Indicates the visibility of the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.visibility IS 'The name for the visibility' ;
COMMENT ON COLUMN tasker.dv_activity.markup_type_id IS 'The ID of the markup format used for the description_markup column.' ;
COMMENT ON COLUMN tasker.dv_activity.markup_type IS 'The name for the markup type' ;
COMMENT ON COLUMN tasker.dv_activity.status_id IS 'The status of the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.status IS 'The name of the status.' ;
COMMENT ON COLUMN tasker.dv_activity.status_category_id IS 'The ID of the category indicating if the status is open, closed, or not open.' ;
COMMENT ON COLUMN tasker.dv_activity.status_category IS 'The name for the status category' ;
COMMENT ON COLUMN tasker.dv_activity.priority_id IS 'The priority of the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.priority IS 'The name for the priority' ;
COMMENT ON COLUMN tasker.dv_activity.desired_start_importance_id IS 'The importance of not making the desired start date.' ;
COMMENT ON COLUMN tasker.dv_activity.desired_start_importance IS 'The name for the desired start importance' ;
COMMENT ON COLUMN tasker.dv_activity.desired_end_importance_id IS 'The importance of not making the desired end date.' ;
COMMENT ON COLUMN tasker.dv_activity.desired_end_importance IS 'The name for the desired end importance' ;
COMMENT ON COLUMN tasker.dv_activity.desired_start IS 'The desired date (if any) that work on the activity should start.' ;
COMMENT ON COLUMN tasker.dv_activity.desired_end IS 'The desired date (if any) for the completion for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.estimated_start IS 'The estimated date (if any) that work on the activity should start.' ;
COMMENT ON COLUMN tasker.dv_activity.estimated_end IS 'The estimated date (if any) for the completion for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.actual_start IS 'The actual date that work on the activity was started.' ;
COMMENT ON COLUMN tasker.dv_activity.actual_end IS 'The actual date that the activity was finished.' ;
COMMENT ON COLUMN tasker.dv_activity.description_markup IS 'A description of the activity and/or the purpose of the activity.' ;
COMMENT ON COLUMN tasker.dv_activity.description_html IS 'The description in HTML format.' ;
COMMENT ON COLUMN tasker.dv_activity.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_activity.created_by IS 'The username of the individual that created the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_activity.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_activity.updated_by IS 'The username of the individual that most recently updated the row (ref pt_user).' ;
COMMENT ON COLUMN tasker.dv_activity.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.dv_activity.updated_dt IS 'The timestamp when the row was most recently updated.' ;
