-- TODO: check this

SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_delete_task (
    a_task_id integer,
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
    l_activity_id integer ;
    l_parent_id integer ;

BEGIN

    IF a_task_id IS NULL OR a_task_id <= 0 THEN
        RETURN false ;
    END IF ;

    -- Ensure there is no time logged against the task
    FOR l_rec IN
        SELECT id
            FROM tasker.dt_task_journal
            WHERE task_id = a_task_id
                AND coalesce ( time_spent, 0.0 ) <> 0.0
        LOOP

        RETURN false ;

    END LOOP ;

    -- Ensure that there are no child tasks
    FOR l_rec IN
        SELECT id
            FROM tasker.dt_task
            WHERE parent_id = a_task_id
        LOOP

        RETURN false ;

    END LOOP ;

    -- Ensure that no other tasks depend on the task
    -- TODO
    FOR l_rec IN
        SELECT task_id
            FROM tasker.dt_task_association
            WHERE task_id = a_task_id
                AND association_type_id = 2
        LOOP

        RETURN false ;

    END LOOP ;


    -- TODO: what else?
    -- Comments?
    -- Files?

    -- Ensure that the user could have created the task
    SELECT activity_id,
            parent_id
        INTO l_activity_id,
            l_parent_id
        FROM tasker.dt_task
        WHERE id = a_task_id ;

    IF NOT user_can_create_task (
            l_parent_id,
            l_activity_id,
            a_username ) THEN

        RETURN false ;

    END IF ;

    RETURN true ;
END ;
$$ ;

ALTER FUNCTION user_can_delete_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_delete_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_delete_task ( integer, varchar ) FROM public ;
