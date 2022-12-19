CREATE TYPE tasker.ut_object_stats AS (
    activity_id integer,
    activity_visibility_id smallint,
    activity_visibility text,
    activity_owner_id integer,
    status_category text,
    ----
    object_type text,
    object_type_id integer,
    object_id integer,
    object_owner_id integer,
    object_assignee_id integer,
    ----
    parent_object_type text,
    parent_object_type_id integer,
    parent_id integer,
    parent_owner_id integer,
    parent_assignee_id integer ) ;

ALTER TYPE tasker.ut_object_stats OWNER TO tasker_owner ;
