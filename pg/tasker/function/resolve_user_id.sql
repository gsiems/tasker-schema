CREATE OR REPLACE FUNCTION tasker.resolve_user_id (
    a_id in integer default null,
    a_user in text default null )
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function resolve_user_id resolves the ID for a user

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | integer    | Unique ID for the user account.                    |
| a_user                         | in     | text       | The username (or ID) associated with the account.  |

*/
DECLARE

    r record ;

BEGIN

    -- Search for a match on the natural key first
    FOR r IN (
        SELECT id
            FROM tasker_data.dt_user
            WHERE username IS NOT DISTINCT FROM trim ( a_user ) ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Search for a match on the primary key second
    FOR r IN (
        SELECT id
            FROM tasker_data.dt_user
            WHERE id IS NOT DISTINCT FROM a_id ) LOOP

        RETURN r.id ;

    END LOOP ;

    -- Finally, search for a match on the natural key parameter matching the primary key
    FOR r IN (
        SELECT id
            FROM tasker_data.dt_user
            WHERE a_id IS NULL
                AND id::text IS NOT DISTINCT FROM a_user ) LOOP

        RETURN r.id ;

    END LOOP ;

    RETURN null::integer ;

END ;
$$ ;

ALTER FUNCTION tasker.resolve_user_id ( integer, text ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.resolve_user_id ( integer, text ) IS 'Returns the ID of a user' ;
