SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_user__insert (
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
    l_rec record ;
    l_session_user_id integer ;
    l_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF NOT user_can_assign_task ( a_task_id, a_session_username ) THEN
            ret.err := 'Insufficient privileges' ;
            RETURN ret ;
        END IF ;

        l_session_user_id = user_id ( a_session_username ) ;
        l_user_id := user_id ( a_username ) ;

        FOR l_rec IN
            SELECT dau.user_id
                FROM tasker.dt_task dt
                JOIN tasker.dt_activity_user dau
                    ON ( dau.activity_id = dt.activity_id )
                WHERE dau.user_id = l_user_id
                    AND dt.id = a_task_id
        LOOP

            INSERT INTO tasker.dt_task_user (
                    task_id,
                    user_id,
                    created_by,
                    created_dt )
                SELECT a_task_id,
                        du.id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC'
                    FROM tasker.dt_user du
                    WHERE du.id = l_user_id
                        AND du.is_enabled
                        AND NOT EXISTS (
                            SELECT 1
                                FROM tasker.dt_task_user dtu
                                WHERE dtu.task_id = a_task_id
                                    AND dtu.user_id = du.id
                        ) ;

            get diagnostics ret.numrows = row_count ;

            RETURN ret ;

        END LOOP ;

        ret.err := 'User not available for assignment' ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION task_user__insert (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_user__insert (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_user__insert (
    integer,
    varchar,
    varchar ) FROM public ;
