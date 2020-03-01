SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_user__set_list (
    a_task_id integer,
    a_user_ids varchar,
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

        IF user_can_assign_task ( a_task_id, a_session_username ) THEN

            l_session_user_id := user_id ( a_session_username ) ;

            WITH ids AS (
                SELECT regexp_split_to_table ( replace ( a_user_ids, ' ', '' ), '[,;]+' ) AS user_id
            ),
            nl AS (
                SELECT du.id AS user_id
                    FROM tasker.dt_user du
                    JOIN ids
                        ON ( ids.user_id = du.id::text
                            OR ids.user_id = du.username )
                    WHERE du.is_enabled
            ),
            ol AS (
                SELECT DISTINCT user_id
                    FROM tasker.dt_task_user
                    WHERE task_id = a_task_id
            ),
            n_list AS (
                SELECT nl.user_id AS new_id,
                        ol.user_id AS old_id
                    FROM nl
                    FULL OUTER JOIN ol
                        ON ( nl.user_id = ol.user_id )
            ),
            inserted AS (
                INSERT INTO tasker.dt_task_user (
                        task_id,
                        user_id,
                        created_by,
                        created_dt )
                    SELECT a_task_id,
                            n_list.new_id,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC'
                        FROM n_list
                        WHERE n_list.old_id IS NULL
                            AND n_list.new_id IS NOT NULL
            )
            DELETE FROM tasker.dt_task_user
                WHERE task_id = a_task_id
                    AND user_id IN (
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

ALTER FUNCTION task_user__set_list (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_user__set_list (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_user__set_list (
    integer,
    varchar,
    varchar ) FROM public ;
