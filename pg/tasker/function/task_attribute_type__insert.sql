SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION task_attribute_type__insert (
    a_category_id integer,
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
    l_id integer ;
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

            WITH a AS (
                INSERT INTO tasker.rt_task_attribute_type (
                        id,
                        category_id,
                        name,
                        description,
                        is_enabled,
                        created_by,
                        created_dt )
                    SELECT nextval ( 'rt_task_attribute_type_id_seq' ),
                            a_category_id,
                            trim ( a_name ),
                            trim ( a_description ),
                            a_is_enabled,
                            l_session_user_id,
                            now () AT TIME ZONE 'UTC' AS created_dt
                        WHERE NOT EXISTS (
                            SELECT 1
                                FROM tasker.rt_task_attribute_type
                                WHERE name = trim ( a_name )
                                    AND category_id = a_category_id )
                        RETURNING id
            )
            SELECT a.id
                INTO ret.id
                FROM a ;

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

ALTER FUNCTION task_attribute_type__insert (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) OWNER TO tasker_owner ;

GRANT ALL ON FUNCTION task_attribute_type__insert (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) TO tasker_user ;

REVOKE ALL ON FUNCTION task_attribute_type__insert (
    integer,
    varchar,
    varchar,
    boolean,
    varchar ) FROM public ;
