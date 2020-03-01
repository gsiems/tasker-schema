SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_watcher__clear (
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
    l_is_admin boolean ;
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_user_id := user_id ( a_username ) ;
        l_session_user_id := user_id ( a_session_username ) ;

        IF l_user_id IS NULL OR l_session_user_id IS NULL THEN
            ret.err := 'Invalid argument' ;
            RETURN ret ;
        END IF ;

        -- Only the owner of the watch should be able to remove a watch.
        -- If it's a really big deal then call in the admin.
        l_is_admin := user_is_admin ( a_session_username ) ;

        IF l_is_admin OR l_session_user_id = l_user_id THEN

            DELETE FROM tasker.dt_task_watcher
                WHERE task_id = a_task_id
                    AND user_id = l_user_id ;

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

ALTER FUNCTION task_watcher__clear (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function task_watcher__clear (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function task_watcher__clear (
    integer,
    varchar,
    varchar ) FROM public ;
