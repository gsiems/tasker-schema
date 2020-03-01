SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_watcher__set (
    a_task_id integer,
    a_username varchar,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_session_user_id integer ;
    l_is_task_owner boolean ;
    l_can_select_task boolean ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_user_id := user_id ( a_username ) ;
        l_session_user_id := user_id ( a_session_username ) ;

        IF l_user_id IS NULL OR l_session_user_id IS NULL THEN
            ret.err := 'Invalid argument' ;
            RETURN false ;
        END IF ;

        l_is_task_owner := user_is_task_owner ( a_session_username ) ;
        l_can_select_task := user_can_select_task ( a_username ) ;

        IF l_can_select_task AND ( l_is_task_owner OR l_user_id = l_session_user_id ) THEN

            INSERT INTO tasker.dt_task_watcher (
                    task_id,
                    user_id,
                    created_by,
                    created_dt )
                SELECT a_task_id,
                        l_user_id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC'
                    WHERE NOT EXISTS (
                        SELECT 1
                            FROM tasker.dt_task_watcher
                            WHERE task_id = a_task_id
                                AND user_id = l_user_id
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

ALTER FUNCTION task_watcher__set (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function task_watcher__set (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function task_watcher__set (
    integer,
    varchar,
    varchar ) FROM public ;
