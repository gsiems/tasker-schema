CREATE VIEW tasker.dv_task_tree
AS
WITH RECURSIVE toc AS (
    SELECT base.id,
            ARRAY [ base.parent_id ] AS parents,
            base.parent_id,
            base.activity_id,
            base.task_type_id,
            0 AS task_depth,
            ARRAY [ dense_rank () OVER (
                PARTITION BY base.activity_id
                ORDER BY base.id ) ] AS outln,
            ARRAY[base.id] AS task_path
        FROM tasker_data.dt_task base
        WHERE base.activity_id = base.parent_id -- only tasks that have an activity for the parent
    UNION ALL
    SELECT base.id,
            parents || base.parent_id,
            base.parent_id,
            base.activity_id,
            base.task_type_id,
            ( q.task_depth + 1 ) AS task_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY base.activity_id, base.parent_id
                    ORDER BY base.id ) ) AS outln,
            q.task_path || base.id
        FROM tasker_data.dt_task base
        JOIN toc q
            ON ( base.parent_id = q.id
                AND base.activity_id <> base.id -- not activities
                AND NOT base.id = ANY ( q.parents ) ) -- avoid cyclic references
)
SELECT toc.id,
        toc.parent_id,
        toc.activity_id,
        rtt.id AS task_type_id,
        rtt.name AS task_type,
        rtt.task_category_id,
        rtt.task_category,
        toc.parents,
        toc.task_depth,
        toc.task_path,
        array_to_string ( toc.outln, '.'::text ) AS outline_label
    FROM toc
    JOIN tasker.rv_task_type rtt
        ON ( rtt.id = toc.task_type_id ) ;

ALTER TABLE tasker.dv_task_tree OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_task_tree TO tasker_owner ;

COMMENT ON VIEW tasker.dv_task_tree IS 'View of the hierarchy of all tasks (by activity).' ;
COMMENT ON COLUMN tasker.dv_task_tree.id IS 'The unique ID for the task.' ;
COMMENT ON COLUMN tasker.dv_task_tree.parent_id IS 'The ID for the parent task.' ;
COMMENT ON COLUMN tasker.dv_task_tree.activity_id IS 'The ID of the activity that the task belongs to.' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_type_id IS 'The ID of the task type' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_type IS 'The name of the task type' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_category_id IS 'The category id for the task type' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_category IS 'The category name for the task type' ;
COMMENT ON COLUMN tasker.dv_task_tree.parents IS 'The array of parent task IDs.' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_depth IS 'Indicates how far the task is from the tree root' ;
COMMENT ON COLUMN tasker.dv_task_tree.task_path IS 'The array of node indexes in the tree (mostly for sorting purposes)' ;
COMMENT ON COLUMN tasker.dv_task_tree.outline_label IS 'The (decimal dotted notation) label for the activity hierarchy outline.' ;
