SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_journal__insert (
    a_parent_id integer,
    a_task_id integer,
    a_username varchar,
    a_journal_date date,
    a_time_spent integer,
    a_markup_type_id integer,
    a_journal_markup text,
    a_journal_html text,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_can_use_task boolean ;
    l_user_id integer ;
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        l_user_id := user_id ( a_username ) ;
        l_session_user_id := user_id ( a_session_username ) ;
        l_can_use_task := user_can_use_task ( a_task_id, a_session_username ) ;

        IF l_can_use_task AND l_session_user_id = l_user_id THEN

            IF journal_markup IS NULL OR length ( trim ( a_journal_markup ) ) = 0 THEN
                a_journal_markup := NULL ;
                a_markup_type_id := NULL ;
                a_journal_html := NULL ;

            END IF ;

            WITH a AS (
                INSERT INTO tasker.dt_task_journal (
                        id,
                        parent_id,
                        task_id,
                        user_id,
                        journal_date,
                        time_spent,
                        markup_type_id,
                        journal_markup,
                        journal_html,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'dt_task_journal_id_seq' ),
                            a_parent_id,
                            a_task_id,
                            l_user_id,
                            a_journal_date,
                            a_time_spent,
                            a_markup_type_id,
                            a_journal_markup,
                            a_journal_html,
                            l_session_user_id,
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

ALTER FUNCTION task_journal__insert (
    integer,
    integer,
    varchar,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_journal__insert (
    integer,
    integer,
    varchar,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_journal__insert (
    integer,
    integer,
    varchar,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) FROM public ;
