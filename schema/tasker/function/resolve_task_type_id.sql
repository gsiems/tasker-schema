CREATE OR REPLACE FUNCTION tasker.resolve_task_type_id (
    a_id in integer default null,
    a_name in text default null,
    a_type_category_id in smallint default null,
    a_type_category in text default null )
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function resolve_task_type_id resolves the ID of a task type

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | integer    | Unique ID for a task type                          |
| a_name                         | in     | text       | The name for a task type.                          |
| a_type_category_id             | in     | smallint   | The ID of the category that the task type belongs to. |
| a_type_category                | in     | text       | The category that the task type belongs to.        |

*/
DECLARE

    r record ;
    l_category_id smallint ;

BEGIN

    l_category_id := tasker.resolve_task_category_id (
        a_id => a_type_category_id,
        a_name => a_type_category ) ;

    -- Search for a match on the natural key first
    IF l_category_id IS NOT NULL THEN
        FOR r IN (
            SELECT id
                FROM tasker_data.rt_task_type
                WHERE task_category_id IS NOT DISTINCT FROM l_category_id
                    AND name IS NOT DISTINCT FROM trim ( a_name ) ) LOOP

            RETURN r.id ;

        END LOOP ;

    ELSE

        -- If no status category specified then try for a distinct name
        FOR r IN (
            SELECT id
                FROM tasker_data.rt_task_type
                WHERE name IS NOT DISTINCT FROM trim ( a_name )
                    AND EXISTS (
                        SELECT 1
                            FROM tasker_data.rt_task_type
                            WHERE name IS NOT DISTINCT FROM trim ( a_name )
                            GROUP BY name
                            HAVING count (*) = 1
                    ) ) LOOP

            RETURN r.id ;

        END LOOP ;

    END IF ;

    -- Search for a match on the primary key second
    FOR r IN (
        SELECT id
            FROM tasker_data.rt_task_type
            WHERE id IS NOT DISTINCT FROM a_id ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Finally, search for a match on the natural key parameter matching the primary key
    FOR r IN (
        SELECT id
            FROM tasker_data.rt_task_type
            WHERE a_id IS NULL
                AND id::text IS NOT DISTINCT FROM a_name ) LOOP

        RETURN r.id ;

    END LOOP ;

    RETURN null::integer ;

END ;
$$ ;

ALTER FUNCTION tasker.resolve_task_type_id ( integer, text, smallint, text ) OWNER TO tasker_owner ;

GRANT EXECUTE ON FUNCTION tasker.resolve_task_type_id ( integer, text, smallint, text ) TO tasker_user ;

COMMENT ON FUNCTION tasker.resolve_task_type_id ( integer, text, smallint, text ) IS 'Returns the ID of a task type' ;
