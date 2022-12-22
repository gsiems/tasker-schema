CREATE OR REPLACE VIEW tasker.dv_activity_tree
AS
WITH RECURSIVE toc AS (
    SELECT base.id,
            '{}'::int[] AS parents,
            base.parent_id,
            0 AS activity_depth,
            ARRAY [ dense_rank () OVER (
                ORDER BY base.id ) ] AS outln,
            ARRAY[base.id] AS activity_path
        FROM tasker_data.dt_task base
        WHERE base.activity_id = base.id -- that are activities
            AND base.parent_id IS NULL
    UNION ALL
    SELECT base.id,
            parents || base.parent_id,
            base.parent_id,
            ( q.activity_depth + 1 ) AS activity_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY base.parent_id
                    ORDER BY base.id ) ) AS outln,
            q.activity_path || base.id
        FROM tasker_data.dt_task base
        JOIN toc q
            ON ( base.parent_id = q.id
                AND base.activity_id = base.id -- is activity
                AND NOT base.id = ANY ( q.parents ) ) -- avoid cyclic references
)
SELECT toc.id,
        toc.parent_id,
        toc.parents,
        toc.activity_depth,
        toc.activity_path,
        array_to_string ( toc.outln, '.'::text ) AS outline_label
    FROM toc ;

ALTER TABLE tasker.dv_activity_tree OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_activity_tree TO tasker_owner ;

COMMENT ON VIEW tasker.dv_activity_tree IS 'View of the hierarchy of activities.' ;
COMMENT ON COLUMN tasker.dv_activity_tree.id IS 'The unique ID for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity_tree.parent_id IS 'The ID for the parent activity.' ;
COMMENT ON COLUMN tasker.dv_activity_tree.parents IS 'The array of parent activity IDs.' ;
COMMENT ON COLUMN tasker.dv_activity_tree.activity_depth IS 'Indicates how far the activity is from the tree root' ;
COMMENT ON COLUMN tasker.dv_activity_tree.activity_path IS 'The array of node indexes in the tree (mostly for sorting purposes)' ;
COMMENT ON COLUMN tasker.dv_activity_tree.outline_label IS 'The (decimal dotted notation) label for the activity hierarchy outline.' ;
