SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_association__delete (
    a_task_id integer,
    a_associated_task_id integer,
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

        -- as specified from the associated task perspective...
        IF user_can_use_task ( a_associated_task_id, a_session_username ) THEN

            DELETE FROM tasker.dt_task_association
                WHERE task_id = a_task_id
                    AND associated_task_id = a_associated_task_id ;

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

ALTER FUNCTION task_association__delete (
    integer,
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_association__delete (
    integer,
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_association__delete (
    integer,
    integer,
    varchar ) FROM public ;
