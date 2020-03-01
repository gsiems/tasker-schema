SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_delete_activity (
    a_activity_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_rec record ;

BEGIN

    -- Only activities that have no undeletable tasks may be deleted.
    -- The activities can't have any children activities either.
    IF user_can_update_activity  (
        a_activity_id,
        a_username ) THEN

        FOR l_rec IN
            SELECT dt.id
                FROM tasker.dt_task dt
                WHERE du.activity_id = a_activity_id
            LOOP

            IF NOT user_can_delete_task (
                    l_rec.task_id,
                    a_username ) THEN
                RETURN false ;
            END IF ;

        END LOOP ;

        FOR l_rec IN
            SELECT id
                FROM tasker.dt_activity
                WHERE parent_id = a_activity_id
            LOOP

            RETURN false ;

        END LOOP ;

        RETURN true ;

    END IF ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_delete_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_delete_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_delete_activity ( integer, varchar ) FROM public ;
