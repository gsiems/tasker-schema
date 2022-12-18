SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity_user__delete (
    a_activity_id integer,
    a_username varchar,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_can_update_activity boolean ;
    l_session_user_id integer ;
    l_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_session_user_id = user_id ( a_session_username ) ;
        l_user_id := user_id ( a_username ) ;
        l_can_update_activity := user_can_update_activity ( a_activity_id, a_session_username ) ;

        IF l_can_update_activity OR l_user_id = l_session_user_id THEN

            -- TODO: if deleting tasks, ensure that tasks can be deleted

            DELETE FROM tasker.dt_activity_user
                WHERE activity_id = a_activity_id
                    AND user_id = l_user_id ;

            get diagnostics ret.numrows = row_count ;

            -- TODO: cascade tasks?

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

ALTER FUNCTION activity_user__delete (
    integer,
    varchar,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity_user__delete (
    integer,
    varchar,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity_user__delete (
    integer,
    varchar,
    varchar ) FROM public ;
