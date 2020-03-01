SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_comment__update (
    a_comment_id integer,
    a_markup_type_id integer,
    a_comment_markup text,
    a_comment_html text,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_is_task_owner boolean ;
    l_task_id integer ;
    l_session_user_id integer ;
    l_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_session_user_id := user_id ( a_session_username ) ;

        SELECT task_id,
                user_id
            INTO l_task_id,
                l_user_id
            FROM tasker.dt_task_comment
            WHERE id = a_comment_id ;

        l_is_task_owner := user_is_task_owner ( l_task_id, a_session_username ) ;

        -- Someone (Task owners) should be able to police bad comments
        -- Users should be able to edit their own comments...
        IF l_is_task_owner OR l_session_user_id = l_user_id THEN

            IF comment_markup IS NULL OR length ( trim ( a_comment_markup ) ) = 0 THEN
                a_comment_markup := NULL ;
                a_markup_type_id := NULL ;
                a_comment_html := NULL ;

            END IF ;

            UPDATE tasker.dt_task_comment
                SET markup_type_id = a_markup_type_id,
                    comment_markup = a_comment_markup,
                    comment_html = a_comment_html,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_comment_id
                    AND ( markup_type_id IS DISTINCT FROM a_markup_type_id
                        OR comment_markup IS DISTINCT FROM a_comment_markup
                        OR comment_html IS DISTINCT FROM a_comment_html ) ;

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

ALTER FUNCTION task_comment__update (
    integer,
    integer,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_comment__update (
    integer,
    integer,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_comment__update (
    integer,
    integer,
    text,
    text,
    varchar ) FROM public ;
