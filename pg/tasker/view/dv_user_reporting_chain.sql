CREATE VIEW tasker.dv_user_reporting_chain
AS
WITH RECURSIVE rcoc AS (
    SELECT p.id,
            '{}'::int[] AS reporting_chain,
            p.supervisor_id,
            0 AS user_depth,
            ARRAY [ dense_rank () OVER (
                ORDER BY p.id ) ] AS outln,
            ARRAY[p.id] AS user_path
        FROM tasker_data.dt_user p
        WHERE ( p.supervisor_id IS NULL )
    UNION ALL
    SELECT s.id,
            reporting_chain || s.supervisor_id,
            s.supervisor_id,
            ( q.user_depth + 1 ) AS user_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY s.supervisor_id
                    ORDER BY s.id ) ) AS outln,
            q.user_path || s.id
        FROM tasker_data.dt_user s
        JOIN rcoc q
            ON ( s.supervisor_id = q.id
                AND NOT s.id = ANY ( q.reporting_chain ) )
)
SELECT id AS user_id,
        reporting_chain,
        supervisor_id,
        user_depth,
        user_path,
        array_to_string ( outln, '.'::text ) AS user_outln
    FROM rcoc ;

ALTER TABLE tasker.dv_user_reporting_chain OWNER TO tasker_owner ;

COMMENT ON VIEW tasker.dv_user_reporting_chain IS 'Org chart (reporting chain of command) for users.' ;
