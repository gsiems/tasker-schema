SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity__update (
    a_activity_id integer,
    a_visibility_id integer,
    a_category_id integer,
    a_status_id integer,
    a_priority_id integer,
    a_markup_type_id integer,
    a_activity_name varchar,
    a_description_markup text,
    a_description_html text,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_can_update_activity ( a_activity_id, a_session_username ) THEN

            IF a_activity_name IS NULL OR trim ( a_activity_name ) = '' THEN
                ret.err := 'Invalid activity name' ;
                RETURN ret ;
            END IF ;

            IF a_description_markup IS NULL OR length ( trim ( a_description_markup ) ) = 0 THEN
                a_description_markup := NULL ;
                a_markup_type_id := NULL ;
                a_description_html := NULL ;

            END IF ;

            l_session_user_id := user_id ( a_session_username ) ;

            UPDATE tasker.dt_activity
                SET visibility_id = a_visibility_id,
                    priority_id = a_priority_id,
                    category_id = a_category_id,
                    status_id = a_status_id,
                    markup_type_id = a_markup_type_id,
                    activity_name = trim ( a_activity_name ),
                    description_markup = a_description_markup,
                    description_html = a_description_html,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_activity_id
                    AND ( visibility_id IS DISTINCT FROM a_visibility_id
                        OR priority_id IS DISTINCT FROM a_priority_id
                        OR category_id IS DISTINCT FROM a_category_id
                        OR status_id IS DISTINCT FROM a_status_id
                        OR markup_type_id IS DISTINCT FROM a_markup_type_id
                        OR activity_name IS DISTINCT FROM a_activity_name
                        OR description_markup IS DISTINCT FROM a_description_markup
                        OR description_html IS DISTINCT FROM a_description_html ) ;

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

ALTER FUNCTION activity__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    integer,
    varchar,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    integer,
    varchar,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity__update (
    integer,
    integer,
    integer,
    integer,
    integer,
    integer,
    varchar,
    text,
    text,
    varchar ) FROM public ;
