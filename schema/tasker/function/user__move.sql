SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__move (
    a_username varchar,
    a_supervisor_id varchar,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_supervisor_id integer ;
    l_session_user_id integer ;
    ret dml_ret ;
    l_count integer ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_is_admin ( a_session_username ) THEN

            l_user_id := user_id ( a_username ) ;
            l_supervisor_id := user_id ( a_supervisor_id ) ;
            l_session_user_id := user_id ( a_session_username ) ;

            IF l_supervisor_id IS NULL THEN

                UPDATE tasker.dt_user
                    SET supervisor_id = NULL,
                        updated_by = l_session_user_id,
                        updated_dt = now () AT TIME ZONE 'UTC'
                    WHERE id = l_user_id
                        AND supervisor_id IS DISTINCT FROM l_supervisor_id ;

                get diagnostics ret.numrows = row_count ;

            ELSE

                IF l_user_id IS NOT DISTINCT FROM l_supervisor_id THEN

                    ret.err := 'A user may not report to themself' ;
                    RETURN ret ;

                END IF ;

                -- Prevent circular references... a person cannot report to an underling
                IF user_is_boss_of ( l_supervisor_id, l_user_id ) THEN

                    ret.err := 'A user may not report to an underling' ;
                    RETURN ret ;

                END IF ;

                UPDATE tasker.dt_user
                    SET supervisor_id = l_supervisor_id,
                        updated_by = l_session_user_id,
                        updated_dt = now () AT TIME ZONE 'UTC'
                    WHERE id = l_user_id
                        AND supervisor_id IS DISTINCT FROM l_supervisor_id ;

                get diagnostics ret.numrows = row_count ;

            END IF ;

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

ALTER FUNCTION user__move (
    varchar,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__move (
    varchar,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__move (
    varchar,
    varchar,
    varchar ) FROM public ;
