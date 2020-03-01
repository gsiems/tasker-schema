SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_journal__list (
    a_task_id integer,
    a_username varchar )
RETURNS TABLE (
        journal_id integer,
        task_id integer,
        task_name varchar,
        user_id integer,
        username varchar,
        journal_date date,
        time_spent integer )
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
    SELECT dtj.journal_id,
            dtj.task_id,
            dtj.task_name,
            dtj.user_id,
            dtj.username,
            dtj.journal_date,
            dtj.time_spent
        FROM tasker.dv_task_journal dtj
        WHERE dtj.task_id = a_task_id
            AND l_user_id IS NOT NULL
            AND ( dtj.user_id = l_user_id
                OR user_can_use_task ( a_task_id, l_user_id ) ) ;

END ;
$$ ;

ALTER FUNCTION task_journal__list (
    integer,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_journal__list (
    integer,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_journal__list (
    integer,
    varchar ) FROM public ;
