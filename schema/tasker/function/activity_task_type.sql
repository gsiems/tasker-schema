SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity_task_type (
    a_activity_id integer )
RETURNS TABLE (
    activity_id integer,
    task_type_id integer,
    task_category_id integer,
    task_category varchar,
    name varchar,
    description varchar,
    template_markup_type_id integer,
    template_markup_type varchar,
    template_markup text,
    template_html text )
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN

    RETURN QUERY
    WITH atl AS (
        SELECT t.activity_id,
                rtt.task_type_id,
                rtt.task_category_id,
                rtt.task_category,
                rtt.name,
                rtt.description,
                rtt.template_markup_type_id,
                rtt.template_markup_type,
                rtt.template_markup,
                rtt.template_html
            FROM tasker.dt_allowed_task_type t
            JOIN tasker.rv_task_type rtt
                ON ( rtt.task_type_id = t.task_type_id )
            WHERE t.activity_id = a_activity_id
                AND rtt.is_enabled
    ),
    hat AS (
        SELECT count (*) AS kount
            FROM atl
    )
    SELECT s.activity_id,
            s.task_type_id,
            s.task_category_id,
            s.task_category,
            s.name,
            s.description,
            s.template_markup_type_id,
            s.template_markup_type,
            s.template_markup,
            s.template_html
        FROM (
            SELECT atl.activity_id,
                    atl.task_type_id,
                    atl.task_category_id,
                    atl.task_category,
                    atl.name,
                    atl.description,
                    atl.template_markup_type_id,
                    atl.template_markup_type,
                    atl.template_markup,
                    atl.template_html
                FROM atl
            UNION
            SELECT a_activity_id AS activity_id,
                    task_type_id,
                    task_category_id,
                    task_category,
                    name,
                    description,
                    template_markup_type_id,
                    template_markup_type,
                    template_markup,
                    template_html
                FROM tasker.rv_task_type
                WHERE is_enabled
                    AND NOT EXISTS (
                        SELECT 1
                            FROM hat
                    )
            ) s
        ORDER BY s.task_type_id ;

END ;
$$ ;

ALTER FUNCTION activity_task_type (
    integer ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity_task_type (
    integer ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity_task_type (
    integer ) FROM public ;
