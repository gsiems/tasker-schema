SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity__user_filter (
    a_username varchar )
RETURNS TABLE (
    edition integer,
    activity_id integer,
    parent_id integer,
    parents text,
    activity_depth integer,
    activity_outln text,
    activity_name varchar,
    is_enabled boolean,
    visibility_id integer,
    visibility varchar,
    category_id integer,
    category_name varchar,
    priority_id integer,
    activity_priority varchar,
    markup_type_id integer,
    markup_type varchar,
    description_markup text,
    description_html text,
    created_dt timestamp with time zone,
    created_by integer,
    updated_dt timestamp with time zone,
    updated_by integer,
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
    SELECT da.edition,
            da.activity_id,
            da.parent_id,
            array_to_string ( da.parents, ',' ) AS parents,
            da.activity_depth,
            da.activity_outln,
            da.activity_name,
            da.is_enabled,
            da.visibility_id,
            da.visibility,
            da.category_id,
            da.category_name,
            da.priority_id,
            da.activity_priority,
            da.markup_type_id,
            da.markup_type,
            da.description_markup,
            da.description_html,
            da.created_dt,
            da.created_by,
            da.updated_dt,
            da.updated_by,
            da.created_username,
            da.created_full_name,
            da.updated_username,
            da.updated_full_name
        FROM tasker.dv_activity da
        WHERE da.visibility_id = 1 --               -- anyone can view the activity, even with no login
            OR ( -------------------------------------------------------
                da.visibility_id = 2
                AND l_user_id IS NOT NULL --        -- user must be logged in, and
                AND EXISTS ( --                     -- be active
                    SELECT 1
                        FROM tasker.dt_user du
                        WHERE du.id = l_user_id
                            AND du.is_enabled )
                )
            OR ( -------------------------------------------------------
                da.visibility_id = 3
                AND l_user_id IS NOT NULL --        -- user must be logged in,
                AND EXISTS ( --                     -- be active, and
                    SELECT 1
                        FROM tasker.dt_user du
                        WHERE du.id = l_user_id
                            AND du.is_enabled )
                AND EXISTS ( --                     --  must be assigned to the activity
                    SELECT 1
                        FROM tasker.dt_activity_user dau
                        WHERE dau.user_id = l_user_id
                            AND dau.activity_id = da.activity_id )
                )
        ORDER BY da.activity_path ;

END ;
$$ ;

ALTER FUNCTION activity__user_filter (
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity__user_filter (
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity__user_filter (
    varchar ) FROM public ;
