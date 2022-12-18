SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity__insert (
    a_parent_id integer,
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

        IF user_can_create_activity ( a_parent_id, a_session_username ) THEN

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

            WITH a AS (
                INSERT INTO tasker.dt_activity (
                        id,
                        parent_id,
                        visibility_id,
                        category_id,
                        status_id,
                        priority_id,
                        markup_type_id,
                        activity_name,
                        description_markup,
                        description_html,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'dt_activity_id_seq' ),
                            CASE
                                WHEN a_parent_id <= 0 THEN NULL
                                ELSE a_parent_id
                                END,
                            a_visibility_id,
                            a_category_id,
                            a_status_id,
                            a_priority_id,
                            a_markup_type_id,
                            trim ( a_activity_name ),
                            a_description_markup,
                            a_description_html,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

            get diagnostics ret.numrows = row_count ;

            -- Set the owner
            INSERT INTO tasker.dt_activity_user (
                    activity_id,
                    user_id,
                    role_id,
                    created_by,
                    created_dt )
                SELECT ret.id,
                        l_session_user_id,
                        1, -- owner role
                        l_session_user_id,
                        now () AT TIME ZONE 'UTC' ;

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

ALTER FUNCTION activity__insert (
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

GRANT ALL ON FUNCTION activity__insert (
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

REVOKE ALL ON FUNCTION activity__insert (
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
