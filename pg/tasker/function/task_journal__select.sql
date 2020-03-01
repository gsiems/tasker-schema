SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_journal__select (
    a_journal_id integer,
    a_username varchar )
RETURNS TABLE (
        ctid text,
        journal_id integer,
        task_id integer,
        task_outln text,
        task_name varchar,
        user_id integer,
        username varchar,
        full_name varchar,
        journal_date date,
        time_spent integer,
        markup_type_id integer,
        markup_type varchar,
        journal_markup text,
        journal_html text,
        created_by integer,
        created_dt timestamp with time zone,
        updated_by integer,
        updated_dt timestamp with time zone,
        created_username varchar,
        created_full_name varchar,
        updated_username varchar,
        updated_full_name varchar )
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_user_id integer ;

BEGIN

    l_user_id := user_id ( a_username ) ;

    RETURN QUERY
    SELECT dtj.ctid,
            dtj.journal_id,
            dtj.task_id,
            dtj.task_outln,
            dtj.task_name,
            dtj.user_id,
            dtj.username,
            dtj.full_name,
            dtj.journal_date,
            dtj.time_spent,
            dtj.markup_type_id,
            dtj.markup_type,
            dtj.journal_markup,
            dtj.journal_html,
            dtj.created_by,
            dtj.created_dt,
            dtj.updated_by,
            dtj.updated_dt,
            dtj.created_username,
            dtj.created_full_name,
            dtj.updated_username,
            dtj.updated_full_name
        FROM tasker.dv_task_journal dtj
        WHERE dtj.journal_id = a_journal_id
            AND l_user_id IS NOT NULL
            AND ( dtj.user_id = l_user_id
                OR user_is_boss_of ( dtj.user_id, l_user_id ) ) ;

END ;
$$ ;

ALTER FUNCTION task_journal__select (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_journal__select (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_journal__select (
    integer,
    varchar ) FROM public ;
