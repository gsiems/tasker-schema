-- TODO

SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_dependency__insert (
    a_task_id integer,
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

            INSERT INTO tasker.dt_task_dependency (
                    task_id,
                    dependent_task_id,
                    created_by,
                    created_dt )
                SELECT a_task_id,
                        a_dependent_task_id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC' AS created_dt
                    WHERE NOT EXISTS (
                            SELECT 1
                                FROM tasker.dt_task_dependency
                                WHERE ( task_id = a_task_id
                                        AND dependent_task_id = a_dependent_task_id )
                                    OR ( task_id = a_dependent_task_id
                                        AND dependent_task_id = a_task_id )
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

ALTER FUNCTION task_dependency__insert (
    integer,
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_dependency__insert (
    integer,
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_dependency__insert (
    integer,
    integer,
    varchar ) FROM public ;
