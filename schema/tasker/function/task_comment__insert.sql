SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_comment__insert (
    a_parent_id integer,
    a_task_id integer,
    a_user_id integer,
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
    l_can_use_task boolean ;
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF user_can_use_task ( a_task_id, a_session_username ) THEN

            IF comment_markup IS NULL OR length ( trim ( a_comment_markup ) ) = 0 THEN
                a_comment_markup := NULL ;
                a_markup_type_id := NULL ;
                a_comment_html := NULL ;

            END IF ;

            l_session_user_id := user_id ( a_session_username ) ;

            WITH a AS (
                INSERT INTO tasker.dt_task_comment (
                        id,
                        parent_id,
                        task_id,
                        user_id,
                        markup_type_id,
                        comment_markup,
                        comment_html,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'dt_task_comment_id_seq' ),
                            a_parent_id,
                            a_task_id,
                            a_user_id,
                            a_markup_type_id,
                            a_comment_markup,
                            a_comment_html,
                            a_session_user_id,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

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

ALTER FUNCTION task_comment__insert (
    integer,
    integer,
    integer,
    integer,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_comment__insert (
    integer,
    integer,
    integer,
    integer,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_comment__insert (
    integer,
    integer,
    integer,
    integer,
    text,
    text,
    varchar ) FROM public ;
