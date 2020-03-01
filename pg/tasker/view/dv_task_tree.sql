SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_tree
AS
WITH RECURSIVE toc AS (
    SELECT p.id,
            '{}'::int[] AS parents,
            p.parent_id,
            0 AS task_depth,
            ARRAY [ dense_rank () OVER (
                PARTITION BY p.activity_id
                ORDER BY p.id ) ] AS outln,
            ARRAY[p.id] AS task_path
        FROM tasker.dt_task p
        JOIN tasker.rt_task_type tt
            ON ( tt.id = p.task_type_id )
        WHERE p.parent_id IS NULL
    UNION ALL
    SELECT s.id,
            parents || s.parent_id,
            s.parent_id,
            ( q.task_depth + 1 ) AS task_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY s.activity_id, s.parent_id
                    ORDER BY s.id ) ) AS outln,
            q.task_path || s.id
        FROM tasker.dt_task s
        JOIN tasker.rt_task_type tt
            ON ( tt.id = s.task_type_id )
        JOIN toc q
            ON ( s.parent_id = q.id
                AND NOT s.id = ANY ( q.parents ) )
)
SELECT id AS task_id,
        parents,
        parent_id,
        task_depth,
        task_path,
        array_to_string ( outln, '.'::text ) AS task_outln
    FROM toc ;

ALTER TABLE dv_task_tree OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_tree IS 'View of the hierarchy of all tasks (by activity).' ;

REVOKE ALL ON table dv_task_tree FROM public ;

GRANT SELECT ON table dv_task_tree TO tasker_owner ;
