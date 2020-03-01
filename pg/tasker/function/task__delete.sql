SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__delete (
    a_task_id integer,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_can_delete_task ( a_task_id, a_session_username ) THEN

            -- Do not delete if there are child tasks
            FOR l_rec IN
                SELECT id
                    FROM tasker.dt_task
                    WHERE parent_id = a_task_id
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete task due to children tasks' ;
                RETURN ret ;

            END LOOP ;

            -- Do not delete if time has been logged
            FOR l_rec IN
                SELECT id
                    FROM tasker.dt_task_journal
                    WHERE task_id = a_task_id
                        AND time_spent IS NOT NULL
                        AND time_spent <> 0
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete task due to time logged' ;
                RETURN ret ;

            END LOOP ;

            -- Do not delete if other tasks depend on it?
            FOR l_rec IN
                SELECT id
                    FROM tasker.dt_task_dependency
                    WHERE task_id = a_task_id
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete task due to dependent tasks' ;
                RETURN ret ;

            END LOOP ;

            ----------------------------------------------------------------
            DELETE FROM tasker.dt_task_user
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_watcher
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_comment
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_file
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_dependency
                WHERE dependent_task_id = a_task_id ;

            DELETE FROM tasker.dt_task_regular
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_requirement
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_issue
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task_meeting
                WHERE task_id = a_task_id ;

            DELETE FROM tasker.dt_task
                WHERE id = a_task_id ;

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

ALTER FUNCTION task__delete (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task__delete (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task__delete (
    integer,
    varchar ) FROM public ;
