SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_activity_tree
AS
WITH RECURSIVE toc AS (
    SELECT base.id,
            '{}'::int[] AS parents,
            base.parent_id,
            0 AS task_depth,
            ARRAY [ dense_rank () OVER (
                PARTITION BY base.activity_id
                ORDER BY base.id ) ] AS outln,
            ARRAY[base.id] AS task_path
        FROM tasker.dt_task base
        WHERE base.activity_id = base.id -- that are activities
            AND base.parent_id IS NULL
    UNION ALL
    SELECT base.id,
            parents || base.parent_id,
            base.parent_id,
            ( q.task_depth + 1 ) AS task_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY base.activity_id, base.parent_id
                    ORDER BY base.id ) ) AS outln,
            q.task_path || base.id
        FROM tasker.dt_task base
        JOIN toc q
            ON ( base.parent_id = q.id
                AND base.activity_id = base.id -- is activity
                AND NOT base.id = ANY ( q.parents ) ) -- avoid cyclic references
)
SELECT toc.id AS task_id,
        toc.parent_id,
        toc.parents,
        toc.task_depth,
        toc.task_path,
        array_to_string ( toc.outln, '.'::text ) AS task_outln
    FROM toc ;

ALTER TABLE dv_activity_tree OWNER TO tasker_owner ;

COMMENT ON VIEW dv_activity_tree IS 'View of the hierarchy of activities.' ;

REVOKE ALL ON TABLE dv_activity_tree FROM public ;

GRANT SELECT ON table dv_activity_tree TO tasker_owner ;
