SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_update_activity (
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
    l_user_id integer ;
    l_parent_id integer ;

BEGIN

    IF a_activity_id IS NULL OR a_activity_id <= 0 THEN
        RETURN false ;
    END IF ;

    -- Activity owners may update any activity (that they own)
    l_user_id := user_id ( a_username ) ;

    FOR l_rec IN
        SELECT du.id
            FROM tasker.dt_user du
            JOIN tasker.dt_activity_user dtu
                ON ( dtu.user_id = du.id )
            JOIN tasker.st_role sr
                ON ( sr.id = dtu.role_id )
            WHERE du.id = l_user_id
                AND du.is_enabled
                AND dtu.activity_id = a_activity_id
                AND ( sr.is_activity_owner )
        LOOP

        RETURN true ;

    END LOOP ;

    IF user_is_admin ( a_username ) THEN
        RETURN true ;
    END IF ;

    SELECT parent_id
        INTO l_parent_id
        FROM tasker.dt_activity
        WHERE id = a_activity_id ;

    -- Non top-level activities may also be updated by the owner of the parent
    IF l_parent_id IS NOT NULL THEN
        FOR l_rec IN
            SELECT du.id
                FROM tasker.dt_user du
                JOIN tasker.dt_activity_user dtu
                    ON ( dtu.user_id = du.id )
                JOIN tasker.st_role sr
                    ON ( sr.id = dtu.role_id )
                WHERE du.id = l_user_id
                    AND du.is_enabled
                    AND dtu.activity_id = l_parent_id
                    AND ( sr.is_activity_owner )
            LOOP

            RETURN true ;

        END LOOP ;

    END IF ;

    RETURN false ;
END ;
$$ ;

ALTER FUNCTION user_can_update_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_update_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_update_activity ( integer, varchar ) FROM public ;
