SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user__delete (
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
    l_rec record ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_is_admin ( a_session_username ) THEN

            -- Ensure user hasn't done anything yet that prevents them being deleted
            l_user_id := user_id ( a_username ) ;

            FOR l_rec IN
                SELECT count ( 1 ) AS ct
                    FROM tasker.dt_user
                    WHERE id = l_user_id
                    LIMIT 1
                LOOP

                IF l_rec.ct = 0 THEN
                    ret.err := 'Failed to delete user due to no such user' ;
                    RETURN ret ;
                END IF ;

            END LOOP ;

            FOR l_rec IN
                SELECT id
                    FROM tasker.dt_user
                    WHERE supervisor_id = l_user_id
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete user due to has underlings' ;
                RETURN ret ;

            END LOOP ;

            FOR l_rec IN
                SELECT user_id
                    FROM tasker.dt_task_journal
                    WHERE user_id = l_user_id
                        AND coalesce ( time_spent, 0.0 ) <> 0.0
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete user due to time logged' ;
                RETURN ret ;

            END LOOP ;

            FOR l_rec IN
                SELECT pc.user_id
                    FROM tasker.dt_task_comment pc
                    WHERE pc.user_id = l_user_id
                        AND NOT EXISTS (
                            SELECT 1
                                FROM tasker.dt_task_comment cc
                                WHERE cc.parent_id = pc.id )
                    LIMIT 1
                LOOP

                ret.err := 'Failed to delete user due to comment replies' ;
                RETURN ret ;

            END LOOP ;

            ----------------------------------------------------------------
            WITH dtj AS (
                DELETE FROM tasker.dt_task_journal
                    WHERE user_id = l_user_id
                        AND coalesce ( time_spent, 0.0 ) <> 0.0
            ),
            dtc AS (
                DELETE FROM tasker.dt_task_comment pc
                    WHERE pc.user_id = l_user_id
                        AND NOT EXISTS (
                            SELECT 1
                                FROM tasker.dt_task_comment cc
                                WHERE cc.parent_id = pc.id )
            ),
            dtu AS (
                DELETE FROM tasker.dt_task_user
                    WHERE user_id = l_user_id
            ),
            dtw AS (
                DELETE FROM tasker.dt_task_watcher
                    WHERE user_id = l_user_id
            ),
            dtp AS (
                DELETE FROM tasker.dt_user_password
                    WHERE user_id = l_user_id
            )
            DELETE FROM tasker.dt_user
                WHERE id = l_user_id ;

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

ALTER FUNCTION user__delete (
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON function user__delete (
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON function user__delete (
    varchar,
    varchar ) FROM public ;
