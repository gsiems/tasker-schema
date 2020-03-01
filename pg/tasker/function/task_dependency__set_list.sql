SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_dependency__set_list (
    a_task_ids varchar,
    a_dependent_task_id integer,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        -- as specified from the dependent task perspective...
        IF user_can_use_task ( a_dependent_task_id, a_session_username ) THEN

            -- TODO: How to best avoid circular dependencies?
            l_session_user_id := user_id ( a_session_username ) ;

            WITH ids AS (
                SELECT regexp_split_to_table ( replace ( a_task_ids, ' ', '' ), '[,;]+' ) AS task_id
            ),
            nl AS (
                SELECT dt.id AS task_id
                    FROM tasker.dt_task dt
                    JOIN ids
                        ON ( ids.task_id = dt.id::text )
            ),
            ol AS (
                SELECT DISTINCT task_id
                    FROM tasker.dt_task_dependency
                    WHERE dependent_task_id = a_dependent_task_id
            ),
            n_list AS (
                SELECT nl.user_id AS new_id,
                        ol.user_id AS old_id
                    FROM nl
                    FULL OUTER JOIN ol
                        ON ( nl.user_id = ol.user_id )
            ),
            inserted AS (
                INSERT INTO tasker.dt_task_dependency (
                        task_id,
                        dependent_task_id,
                        created_by,
                        created_dt )
                    SELECT n_list.new_id
                            a_dependent_task_id,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC'
                        FROM n_list
                        WHERE n_list.old_id IS NULL
                            AND n_list.new_id IS NOT NULL
            )
            DELETE FROM tasker.dt_task_dependency
                WHERE dependent_task_id = a_dependent_task_id
                    AND task_id IN (
                        SELECT n_list.old_id
                            FROM n_list
                            WHERE n_list.new_id IS NULL
                                AND n_list.old_id IS NOT NULL
                        ) ;

            get diagnostics ret.numrows = row_count ;

        ELSE
            ret.err := 'Insufficient privileges' ;

        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION task_dependency__set_list (
    varchar,
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_dependency__set_list (
    varchar,
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_dependency__set_list (
    varchar,
    integer,
    varchar ) FROM public ;
