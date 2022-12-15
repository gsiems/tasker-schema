SET search_path = tasker, pg_catalog ;

CREATE VIEW dv_user_cc
AS
WITH RECURSIVE coc AS (
    SELECT p.id,
            '{}'::int[] AS bosses,
            p.reports_to,
            0 AS user_depth,
            ARRAY [ dense_rank () OVER (
                ORDER BY p.id ) ] AS outln,
            ARRAY[p.id] AS user_path
        FROM tasker.dt_user p
        WHERE ( p.reports_to IS NULL )
    UNION ALL
    SELECT s.id,
            bosses || s.reports_to,
            s.reports_to,
            ( q.user_depth + 1 ) AS user_depth,
            ( q.outln || dense_rank () OVER (
                    PARTITION BY s.reports_to
                    ORDER BY s.id ) ) AS outln,
            q.user_path || s.id
        FROM tasker.dt_user s
        JOIN coc q
            ON ( s.reports_to = q.id
                AND NOT s.id = ANY ( q.bosses ) )
)
SELECT id AS user_id,
        bosses,
        reports_to,
        user_depth,
        user_path,
        array_to_string ( outln, '.'::text ) AS user_outln
    FROM coc ;

ALTER TABLE dv_user_cc OWNER TO tasker_owner ;

COMMENT ON VIEW dv_user_cc IS 'Org chart (chain of command) for users.' ;

REVOKE ALL ON TABLE dv_user_cc FROM public ;

GRANT SELECT ON table dv_user_cc TO tasker_owner ;
