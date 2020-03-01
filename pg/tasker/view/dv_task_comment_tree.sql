SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_task_comment_tree
AS
WITH RECURSIVE toc AS (
    SELECT p.id,
            '{}'::int [ ] AS parents,
            p.parent_id,
            0 AS comment_depth,
            array [ dense_rank () OVER (
                PARTITION BY p.task_id
                ORDER BY p.id ) ] AS outln,
            ARRAY[p.id] AS comment_path
        FROM dt_task_comment p
        WHERE ( p.parent_id IS NULL )
    UNION ALL
    SELECT s.id,
            parents || s.parent_id,
            s.parent_id,
            ( q.comment_depth + 1 ) AS comment_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY  s.task_id, s.parent_id
                    ORDER BY s.id ) ),
            q.comment_path || s.id
        FROM dt_task_comment s
        JOIN toc q
            ON ( s.parent_id = q.id
                AND NOT s.id = any ( q.parents ) )
)
SELECT id AS comment_id,
        parents,
        parent_id,
        comment_depth,
        comment_path,
        array_to_string ( outln, '.'::text ) AS comment_outln
    FROM toc ;

ALTER TABLE dv_task_comment_tree OWNER TO tasker_owner ;

COMMENT ON VIEW dv_task_comment_tree IS 'Table of contents view for task comments.' ;

REVOKE ALL ON table dv_task_comment_tree FROM public ;

GRANT SELECT ON table dv_task_comment_tree TO tasker_owner ;
