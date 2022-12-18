SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_type__delete (
    a_id integer,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_is_admin ( a_session_username ) THEN

            -- Only unused task types may be deleted
            DELETE FROM tasker.rt_task_type
                WHERE id = a_id
                    AND NOT EXISTS (
                        SELECT 1
                            FROM tasker.dt_task
                            WHERE task_type_id = a_id ) ;

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

ALTER FUNCTION task_type__delete (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_type__delete (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_type__delete (
    integer,
    varchar ) FROM public ;
