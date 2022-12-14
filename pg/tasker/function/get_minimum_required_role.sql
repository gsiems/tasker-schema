CREATE OR REPLACE FUNCTION tasker.get_minimum_required_role (
    a_action text default null,
    a_object_type text default null )
RETURNS smallint
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
/**
Function get_minimum_required_role returns the minimum role required to perform the specified action

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_action                       | in     | text       | The action to perform                              |
| a_object_type                  | in     | text       | The (name of) the type of object to perform the action on |

*/

SELECT minimum_role_id
    FROM tasker.sv_object_permission
    WHERE object_type = a_object_type
        AND action = a_action
        AND is_enabled ;

$$ ;

ALTER FUNCTION tasker.get_minimum_required_role ( text, text ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.get_minimum_required_role ( text, text ) IS 'Returns the minimum role required to perform the specified action' ;
