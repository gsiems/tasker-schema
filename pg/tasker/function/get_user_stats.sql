CREATE OR REPLACE FUNCTION tasker.get_user_stats (
    a_id in integer default null,
    a_user in text default null )
RETURNS tasker.ut_user_stats
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function get_user_stats returns the statistics for the specified user

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_id                           | in     | integer    | Unique ID for the user account.                    |
| a_user                         | in     | text       | The username (or ID) associated with the account.  |

*/
DECLARE

    r record ;
    l_stats tasker.ut_user_stats ;
    l_user_id integer ;

BEGIN

    l_stats.is_public := true ;
    l_stats.is_enabled := false ;
    l_stats.is_admin := false ;
    l_stats.can_create_activities := false ;

    l_user_id := a_id ;
    IF l_user_id IS NULL THEN
        l_user_id := tasker.resolve_user_id ( a_user => a_user ) ;
    END IF ;

    FOR r IN (
        SELECT id,
                username,
                is_enabled,
                is_admin,
                can_create_activities
            FROM tasker_data.dt_user
            WHERE id = l_user_id ) LOOP

        l_stats.user_id := r.id ;
        l_stats.username := r.username ;
        l_stats.is_enabled := r.is_enabled ;
        l_stats.is_admin := r.is_admin ;
        l_stats.can_create_activities := r.can_create_activities ;

        IF r.is_admin AND r.id > 0 AND r.username <> 'public' THEN
            l_stats.is_public := false ;
        END IF ;

    END LOOP ;

    RETURN l_stats ;

END ;
$$ ;

ALTER FUNCTION tasker.get_user_stats ( integer, text ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.get_user_stats ( integer, text ) IS 'Returns the statistics for the specified user' ;
