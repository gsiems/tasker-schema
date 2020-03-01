SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_activity_tree
AS
WITH RECURSIVE toc AS (
    SELECT p.id,
            '{}'::int[] AS parents,
            p.parent_id,
            0 AS activity_depth,
            ARRAY [ dense_rank () OVER (
                ORDER BY p.id ) ] AS outln,
            ARRAY[p.id] AS activity_path
        FROM tasker.dt_activity p
        WHERE ( p.parent_id IS NULL )
    UNION ALL
    SELECT s.id,
            parents || s.parent_id,
            s.parent_id,
            ( q.activity_depth + 1 ) AS activity_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY s.parent_id
                    ORDER BY s.id ) ) AS outln,
            q.activity_path || s.id
        FROM tasker.dt_activity s
        JOIN toc q
            ON ( s.parent_id = q.id
                AND NOT s.id = ANY ( q.parents ) )
)
SELECT id AS activity_id,
        parents,
        parent_id,
        activity_depth,
        activity_path,
        array_to_string ( outln, '.'::text ) AS activity_outln
    FROM toc ;

ALTER TABLE dv_activity_tree OWNER TO tasker_owner ;

COMMENT ON VIEW dv_activity_tree IS 'View of the hierarchy of activities.' ;

REVOKE ALL ON table dv_activity_tree FROM public ;

GRANT SELECT ON table dv_activity_tree TO tasker_owner ;
