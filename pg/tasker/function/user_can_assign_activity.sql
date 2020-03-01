SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_assign_activity (
    a_activity_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN tasker.user_can_update_activity (
        a_activity_id,
        a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_assign_activity ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_assign_activity ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_assign_activity ( integer, varchar ) FROM public ;
