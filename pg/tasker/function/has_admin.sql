SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION has_admin ( )
RETURNS boolean
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_test integer ;

BEGIN

    SELECT id
        INTO l_test
        FROM tasker.dt_user
        WHERE is_admin
            AND is_enabled
        LIMIT 1 ;

    RETURN ( l_test IS NOT NULL ) ;

END ;
$$ ;

ALTER FUNCTION has_admin ( ) OWNER TO tasker_owner ;

GRANT ALL ON function has_admin ( ) TO tasker_user ;

REVOKE ALL ON function has_admin ( ) FROM public ;
