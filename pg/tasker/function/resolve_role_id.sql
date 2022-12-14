/*
psql -t -c "SELECT util_meta.mk_resolve_id_function (
         a_object_schema => 'tasker_data',
         a_object_name => 'st_role',
         a_ddl_schema => 'tasker',
         a_owner => 'tasker_owner' ) ;" tasker | sed -e 's/[[:space:]]*+$//' -e 's/^ //' > tasker/function/resolve_role_id.sql

*/
CREATE OR REPLACE FUNCTION tasker.resolve_role_id (
    a_id in smallint default null,
    a_name in text default null )
RETURNS smallint
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function resolve_role_id resolves the ID of a role

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | smallint   | Unique ID for the role.                            |
| a_name                         | in     | text       | The name for the role.                             |

*/
DECLARE

    r record ;

BEGIN

    -- Search for a match on the natural key first
    FOR r IN (
        SELECT id
            FROM tasker_data.st_role
            WHERE name IS NOT DISTINCT FROM trim ( a_name ) ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Search for a match on the primary key second
    FOR r IN (
        SELECT id
            FROM tasker_data.st_role
            WHERE id IS NOT DISTINCT FROM a_id ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Finally, search for a match on the natural key parameter matching the primary key
    FOR r IN (
        SELECT id
            FROM tasker_data.st_role
            WHERE a_id IS NULL
                AND id::text IS NOT DISTINCT FROM a_name ) LOOP

        RETURN r.id ;

    END LOOP ;

    RETURN null::smallint ;

END ;
$$ ;

ALTER FUNCTION tasker.resolve_role_id ( smallint, text ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.resolve_role_id ( smallint, text ) IS 'Returns the ID of a role' ;
