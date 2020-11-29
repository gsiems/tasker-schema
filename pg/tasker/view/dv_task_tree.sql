SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_tree
AS
WITH RECURSIVE toc AS (
    SELECT base.id,
            '{}'::int[] AS parents,
            base.parent_id,
            base.activity_id,
            base.task_type_id,
            0 AS task_depth,
            ARRAY [ dense_rank () OVER (
                PARTITION BY base.activity_id
                ORDER BY base.id ) ] AS outln,
            ARRAY[base.id] AS task_path
        FROM tasker.dt_task base
        JOIN tasker.dt_task p -- only tasks that have an activity for the parent
            ON ( p.id = base.parent_id
                AND p.id = p.activity_id )
        WHERE base.activity_id <> base.id -- that are not activities
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
        FROM tasker.dt_task base
        JOIN toc q
            ON ( base.parent_id = q.id
                AND base.activity_id <> base.id -- not activities
                AND NOT base.id = ANY ( q.parents ) ) -- avoid cyclic references
)
SELECT toc.id AS task_id,
        toc.parent_id,
        toc.activity_id,
        tt.category_id,
        tc.name AS category,
        toc.parents,
        toc.task_depth,
        toc.task_path,
        array_to_string ( toc.outln, '.'::text ) AS task_outln
    FROM toc
    JOIN tasker.rt_task_type tt
        ON ( tt.id = toc.task_type_id )
    JOIN tasker.st_task_category tc
        ON ( tc.id = tt.category_id ) ;

ALTER TABLE dv_task_tree OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_tree IS 'View of the hierarchy of all tasks (by activity).' ;

REVOKE ALL ON TABLE dv_task_tree FROM public ;

GRANT SELECT ON table dv_task_tree TO tasker_owner ;
