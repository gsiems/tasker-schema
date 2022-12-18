
CREATE OR REPLACE FUNCTION activity__move (
    a_activity_id integer,
    a_new_parent_id integer,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;
    l_session_user_id int ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF a_new_parent_id <= 0 THEN
            a_new_parent_id := NULL ;
        END IF ;

        FOR l_rec IN
            SELECT id
                FROM tasker.dt_activity
                WHERE id = a_activity_id
                    AND parent_id IS NOT DISTINCT FROM a_new_parent_id
            LOOP

            -- already moved
            RETURN ret ;

        END LOOP ;

        IF user_can_move_activity ( a_activity_id, a_new_parent_id, a_session_username ) THEN

            l_session_user_id := user_id ( a_session_username ) ;

            UPDATE dt_activity
                SET parent_id = CASE
                        WHEN a_new_parent_id <= 0 THEN NULL
                        ELSE a_new_parent_id
                        END,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_activity_id
                    AND ( parent_id IS DISTINCT FROM a_new_parent_id ) ;

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

ALTER FUNCTION activity__move ( integer, integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity__move ( integer, integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity__move ( integer, integer, varchar ) FROM public ;
