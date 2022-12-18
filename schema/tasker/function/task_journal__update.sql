SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_journal__update (
    a_journal_id integer,
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
            FROM tasker.dt_task_journal
            WHERE id = a_journal_id ;

        l_is_task_owner := user_is_task_owner ( l_task_id, a_session_username ) ;

        -- Someone (Task Owners?) should be able to police bad journals
        -- Users should be able to edit their own journals...
        IF l_is_task_owner OR l_session_user_id = l_user_id THEN

            IF journal_markup IS NULL OR length ( trim ( a_journal_markup ) ) = 0 THEN
                a_journal_markup := NULL ;
                a_markup_type_id := NULL ;
                a_journal_html := NULL ;

            END IF ;

            UPDATE tasker.dt_task_journal
                SET journal_date = a_journal_date,
                    time_spent = a_time_spent,
                    markup_type_id = a_markup_type_id,
                    journal_markup = a_journal_markup,
                    journal_html = a_journal_html,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_journal_id
                    AND ( journal_date IS DISTINCT FROM a_journal_date
                        OR time_spent IS DISTINCT FROM a_time_spent
                        OR markup_type_id IS DISTINCT FROM a_markup_type_id
                        OR journal_markup IS DISTINCT FROM a_journal_markup
                        OR journal_html IS DISTINCT FROM a_journal_html ) ;

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

ALTER FUNCTION task_journal__update (
    integer,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_journal__update (
    integer,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_journal__update (
    integer,
    date,
    integer,
    integer,
    text,
    text,
    varchar ) FROM public ;
