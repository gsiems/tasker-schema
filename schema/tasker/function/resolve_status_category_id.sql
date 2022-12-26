CREATE OR REPLACE FUNCTION tasker.resolve_status_category_id (
    a_id in smallint default null,
    a_name in text default null )
RETURNS smallint
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function resolve_status_category_id resolves the ID of a status category

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | smallint   | Unique ID for an status category.                  |
| a_name                         | in     | text       | The name for an status category.                   |

*/
DECLARE

    r record ;

BEGIN

    -- Search for a match on the natural key first
    FOR r IN (
        SELECT id
            FROM tasker_data.st_status_category
            WHERE name IS NOT DISTINCT FROM trim ( a_name ) ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Search for a match on the primary key second
    FOR r IN (
        SELECT id
            FROM tasker_data.st_status_category
            WHERE id IS NOT DISTINCT FROM a_id ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Finally, search for a match on the natural key parameter matching the primary key
    FOR r IN (
        SELECT id
            FROM tasker_data.st_status_category
            WHERE a_id IS NULL
                AND id::text IS NOT DISTINCT FROM a_name ) LOOP

        RETURN r.id ;

    END LOOP ;

    RETURN null::smallint ;

END ;
$$ ;

ALTER FUNCTION tasker.resolve_status_category_id ( smallint, text ) OWNER TO tasker_owner ;

GRANT EXECUTE ON FUNCTION tasker.resolve_status_category_id ( smallint, text ) TO tasker_user ;

COMMENT ON FUNCTION tasker.resolve_status_category_id ( smallint, text ) IS 'Returns the ID of a status category' ;
