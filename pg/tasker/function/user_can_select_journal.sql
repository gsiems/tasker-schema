SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_select_journal (
    a_journal_id integer,
    a_task_id integer,
    a_username varchar,
    a_session_username varchar )
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
    l_session_user_id integer ;

BEGIN

    l_user_id := user_id ( a_username ) ;
    l_session_user_id := user_id ( a_session_username ) ;

    IF l_user_id IS NULL OR l_session_user_id IS NULL THEN
        RETURN false ;
    END IF ;

    -- if the user can see the task then they can see the journal(s)
    -- if the user is a boss of the user that the owns the journal then they can see the journal
    -- if the user is the author of the journal then they can see the journal

    IF a_journal_id IS NOT NULL THEN
        -- we're dealing with a single journal entry

        FOR l_rec IN
            SELECT task_id,
                    user_id
                FROM tasker.dt_task_journal
                WHERE journal_id = a_journal_id
                LIMIT 1
            LOOP

            IF l_user_id = l_rec.user_id THEN
                IF l_user_id = l_session_user_id THEN
                    RETURN true ;
                END IF ;

                IF user_is_boss_of ( l_user_id, l_session_user_id ) THEN
                    RETURN true ;
                END IF ;

                IF user_can_use_task ( l_rec.task_id, l_user_id ) THEN
                    RETURN true ;
                END IF ;

            END IF ;

        END LOOP ;

        RETURN false ;

    END IF ;

    IF a_task_id IS NOT NULL THEN

        IF user_can_use_task ( a_task_id, l_user_id ) THEN
            RETURN true ;
        END IF ;

    END IF ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION user_can_select_journal ( integer, integer, varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_select_journal ( integer, integer, varchar, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_select_journal ( integer, integer, varchar, varchar ) FROM public ;
