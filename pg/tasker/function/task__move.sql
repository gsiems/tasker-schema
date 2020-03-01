SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task__move (
    a_task_id integer,
    a_new_activity_id integer,
    a_new_parent_id integer,
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

        IF user_can_move_task (
                a_task_id,
                a_new_activity_id,
                a_new_parent_id,
                a_session_username ) THEN

            l_session_user_id := user_id ( a_session_username ) ;

            UPDATE tasker.dt_task
                SET parent_id = a_new_parent_id,
                    activity_id = a_new_activity_id,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_task_id
                    AND parent_id IS DISTINCT FROM a_parent_id
                    AND activity_id IS DISTINCT FROM a_new_activity_id ;

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

ALTER FUNCTION task__move (
    integer,
    integer,
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function task__move (
    integer,
    integer,
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON function task__move (
    integer,
    integer,
    integer,
    varchar ) FROM public ;

/*

TODO: do we want a task__move (_task_id, a_parent_id, a_activity_id,
_session_username ) for moving tasks to different activities. This
would also need to move any children tasks... or would that be an
option? What would it look like to move a task to a different activity
but not move the sub-tasks?

*/
