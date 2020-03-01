SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION activity_attribute_type__update (
    a_id integer,
    a_name varchar,
    a_description varchar,
    a_is_enabled boolean,
    a_session_username varchar )
RETURNS dml_ret
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    l_session_user_id integer ;
    ret dml_ret ;

BEGIN

    ret.numrows := 0 ;

    BEGIN

        IF a_name IS NULL OR trim ( a_name ) = '' THEN
            ret.err := 'Invalid argument' ;
            RETURN ret ;
        END IF ;

        IF user_is_admin ( a_session_username ) THEN

            l_session_user_id := user_id ( a_session_username ) ;

            UPDATE tasker.rt_activity_attribute_type
                SET name = trim ( a_name ),
                    description = trim ( a_description ),
                    is_enabled = a_is_enabled,
                    updated_by = l_session_user_id,
                    updated_dt = now () AT TIME ZONE 'UTC'
                WHERE id = a_id
                    AND ( name IS DISTINCT FROM trim ( a_name )
                        OR description IS DISTINCT FROM trim ( a_description )
                        OR is_enabled IS DISTINCT FROM coalesce ( a_is_enabled, is_enabled ) )
                    AND NOT EXISTS (
                        SELECT 1
                            FROM tasker.rt_activity_attribute_type
                            WHERE id <> a_id
                                AND category_id = a_category_id
                                AND name = trim ( a_name ) ) ;

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

ALTER FUNCTION activity_attribute_type__update (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION activity_attribute_type__update (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION activity_attribute_type__update (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) FROM public ;
