SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_is_boss_of (
    a_user_id integer,
    a_boss_id integer )
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

    IF a_user_id IS NULL OR a_boss_id IS NULL THEN
        RETURN false ;
    END IF ;

    IF a_user_id = a_boss_id THEN
        RETURN false ;
    END IF ;

    FOR l_rec IN
        SELECT 1
            FROM tasker.dv_user_cc cc
            WHERE cc.user_id = a_user_id
                AND a_boss_id = ANY ( cc.bosses )
            LIMIT 1
        LOOP

        RETURN true ;

    END LOOP ;

    RETURN false ;

END ;
$$ ;

ALTER FUNCTION user_is_boss_of ( integer, integer ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_is_boss_of ( integer, integer ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_is_boss_of ( integer, integer ) FROM public ;


CREATE OR REPLACE FUNCTION user_is_boss_of (
    a_username varchar,
    a_boss_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;
    l_boss_id integer ;

BEGIN

    l_user_id := user_id ( a_username ) ;
    l_boss_id := user_id ( a_boss_username ) ;

    RETURN user_is_boss_of ( l_user_id, l_boss_id ) ;

END ;
$$ ;

ALTER FUNCTION user_is_boss_of ( varchar, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_is_boss_of ( varchar, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_is_boss_of ( varchar, varchar ) FROM public ;


CREATE OR REPLACE FUNCTION user_is_boss_of (
    a_user_id integer,
    a_boss_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_boss_id integer ;

BEGIN

    l_boss_id := user_id ( a_boss_username ) ;
    RETURN user_is_boss_of ( a_user_id, l_boss_id ) ;

END ;
$$ ;

ALTER FUNCTION user_is_boss_of ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_is_boss_of ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_is_boss_of ( integer, varchar ) FROM public ;
