CREATE TYPE tasker.ut_user_stats AS (
    user_id integer,
    username text,
    is_enabled boolean,
    is_admin boolean,
    is_public boolean,
    can_create_activities boolean ) ;

ALTER TYPE tasker.ut_object_stats OWNER TO tasker_owner ;
