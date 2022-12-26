CREATE OR REPLACE FUNCTION tasker.resolve_task_status_id (
    a_id in integer default null,
    a_name in text default null )
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function resolve_task_status_id resolves the ID of a task status

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | integer    | Unique ID for the status                           |
| a_name                         | in     | text       | The name of the status.                            |

*/
DECLARE

    r record ;

BEGIN

    -- Search for a match on the natural key first
    FOR r IN (
        SELECT id
            FROM tasker_data.rt_task_status
            WHERE name IS NOT DISTINCT FROM trim ( a_name ) ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Search for a match on the primary key second
    FOR r IN (
        SELECT id
            FROM tasker_data.rt_task_status
            WHERE id IS NOT DISTINCT FROM a_id ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Finally, search for a match on the natural key parameter matching the primary key
    FOR r IN (
        SELECT id
            FROM tasker_data.rt_task_status
            WHERE a_id IS NULL
                AND id::text IS NOT DISTINCT FROM a_name ) LOOP

        RETURN r.id ;

    END LOOP ;

    RETURN null::integer ;

END ;
$$ ;

ALTER FUNCTION tasker.resolve_task_status_id ( integer, text ) OWNER TO tasker_owner ;

GRANT EXECUTE ON FUNCTION tasker.resolve_task_status_id ( integer, text ) TO tasker_user ;

COMMENT ON FUNCTION tasker.resolve_task_status_id ( integer, text ) IS 'Returns the ID of a task status' ;
