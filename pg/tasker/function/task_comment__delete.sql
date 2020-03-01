SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_comment__delete (
    a_comment_id integer,
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

        l_session_user_id := user_id ( a_session_username ) ;

        -- Users should be able to remove their own comments...
        -- as long as they have not been replied to
        DELETE FROM tasker.dt_task_comment
            WHERE id = a_comment_id
                AND user_id = l_session_user_id
                AND NOT EXISTS (
                    SELECT 1
                        FROM tasker.dt_task_comment
                        WHERE parent_id = a_comment_id
                    ) ;

        get diagnostics ret.numrows = row_count ;

    EXCEPTION
        WHEN OTHERS THEN
            ret.err := substr ( SQLSTATE::text || ' - ' || SQLERRM, 1, 400 ) ;

    END ;

    RETURN ret ;
END ;
$$ ;

ALTER FUNCTION task_comment__delete (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_comment__delete (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_comment__delete (
    integer,
    varchar ) FROM public ;
