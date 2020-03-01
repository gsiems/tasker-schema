-- TODO: check this

SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_can_assign_task (
    a_task_id integer,
    a_username varchar )
RETURNS boolean
STABLE
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN

    RETURN user_can_update_task ( a_task_id, a_username ) ;

END ;
$$ ;

ALTER FUNCTION user_can_assign_task ( integer, varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION user_can_assign_task ( integer, varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION user_can_assign_task ( integer, varchar ) FROM public ;
