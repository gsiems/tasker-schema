SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity_user__upsert (
    a_activity_id integer,
    a_role_id integer,
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

        IF user_can_update_activity ( a_activity_id, a_session_username ) THEN

            l_session_user_id = user_id ( a_session_username ) ;
            l_user_id := user_id ( a_username ) ;

            FOR l_rec IN
                SELECT du.id
                    FROM tasker.dt_user du
                    WHERE du.id = l_user_id
                        AND NOT du.is_enabled
                LOOP

                ret.err := 'User account is disabled' ;

                RETURN ret ;

            END LOOP ;


            FOR l_rec IN
                SELECT dtu.role_id
                    FROM tasker.dt_activity_user dtu
                    WHERE dtu.activity_id = a_activity_id
                        AND user_id = l_user_id
                LOOP

                    UPDATE tasker.dt_activity_user
                        SET role_id = a_role_id,
                            updated_by = l_session_user_id,
                            updated_dt = now () AT TIME ZONE 'UTC'
                        WHERE activity_id = a_activity_id
                            AND user_id = l_user_id
                            AND role_id IS DISTINCT FROM a_role_id
                            AND EXISTS (
                                SELECT 1
                                    FROM tasker.st_role
                                    WHERE id = a_role_id ) ;

                get diagnostics ret.numrows = row_count ;

                RETURN ret ;

            END LOOP ;

            INSERT INTO tasker.dt_activity_user (
                    activity_id,
                    user_id,
                    role_id,
                    created_by,
                    created_dt )
                SELECT a_activity_id,
                        du.id,
                        a_role_id,
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC'
                    FROM tasker.dt_user du
                    WHERE du.id = l_user_id
                        AND du.is_enabled
                        AND NOT EXISTS (
                            SELECT 1
                                FROM tasker.dt_activity_user dau
                                WHERE dau.activity_id = a_activity_id
                                    AND dau.user_id = du.id
                        )
                        AND EXISTS (
                            SELECT 1
                                FROM tasker.st_role
                                WHERE id = a_role_id
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

ALTER FUNCTION activity_user__upsert (
    integer,
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity_user__upsert (
    integer,
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity_user__upsert (
    integer,
    integer,
    varchar,
    varchar ) FROM public ;
