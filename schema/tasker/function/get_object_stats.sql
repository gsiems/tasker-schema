CREATE OR REPLACE FUNCTION tasker.get_object_stats (
    a_object_type in text default null,
    a_id in integer default null,
    a_parent_object_type in text default null,
    a_parent_id in integer default null )
RETURNS tasker.ut_object_stats
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
/**
Function get_object_stats returns the statistics for the specified object

| Parameter                      | In/Out | Datatype   | Remarks                                            |
| ------------------------------ | ------ | ---------- | -------------------------------------------------- |
| a_object_type                  | in     | text       | The (name of) the type of object to get statistics on |
| a_id                           | in     | integer    | The ID of the object to get statistics on          |
| a_parent_object_type           | in     | text       | The (name of) the type of object that is the parent of the object to get statistics on |
| a_parent_id                    | in     | integer    | The ID of the parent object to get statistics on   |

NOTES

* Valid object types are defined in tasker_data.st_object_type

*/
DECLARE

    r record ;
    l_stats tasker.ut_object_stats ;

BEGIN

    ----------------------------------------------------------------------------
    -- Ensure that there is a specified object type
    IF a_object_type IS NULL THEN
        RETURN l_stats ;
    END IF ;

    ----------------------------------------------------------------------------
    -- Ensure that the specified object type is valid and enabled
    FOR r IN (
        SELECT id,
                lower ( name ) AS object_type
            FROM tasker_data.st_object_type
            WHERE lower ( name ) = lower ( a_object_type )
                AND is_enabled ) LOOP

        l_stats.object_type := r.object_type ;
        l_stats.object_type_id := r.id ;

    END LOOP ;

    IF l_stats.object_type IS NULL THEN
        RETURN l_stats ;
    END IF ;

    ----------------------------------------------------------------------------
    IF l_stats.object_type IN ( 'reference', 'user', 'profile' ) THEN
        -- These have no parent per se. Neither do they have an owner or assignee as such
        RETURN l_stats ;
    END IF ;

    IF a_id IS NOT NULL THEN

        IF l_stats.object_type = 'comment' THEN

            FOR r IN (
                SELECT base.id AS object_id,
                        task.activity_id,
                        CASE
                            WHEN task.id = task.activity_id THEN 'activity'
                            ELSE lower ( tc.name )
                            END AS parent_object_type,
                        base.task_id AS parent_id, -- note that the parent is the task and not the parent comment (if any)
                        base.created_by_id AS object_owner_id,
                        coalesce ( task.owner_id, task.created_by_id ) AS parent_owner_id
                    FROM tasker_data.dt_task_comment base
                    JOIN tasker_data.dt_task task
                        ON ( task.id = base.task_id )
                    JOIN tasker_data.st_task_category tc
                        ON ( tc.id = task.task_type_id )
                    WHERE base.id = a_id ) LOOP

                l_stats.activity_id := r.activity_id ;
                l_stats.object_id = r.object_id ;
                l_stats.object_owner_id := r.object_owner_id ;
                l_stats.parent_id := r.parent_id ;
                l_stats.parent_object_type := r.parent_object_type ;
                l_stats.parent_owner_id := r.parent_owner_id ;

            END LOOP ;

        ELSIF l_stats.object_type = 'journal' THEN

            FOR r IN (
                SELECT base.id AS object_id,
                        task.activity_id,
                        CASE
                            WHEN task.id IS NOT DISTINCT FROM task.activity_id THEN 'activity'
                            ELSE lower ( tc.name )
                            END AS parent_object_type,
                        base.task_id AS parent_id,
                        base.created_by_id AS object_owner_id,
                        coalesce ( task.owner_id, task.created_by_id ) AS parent_owner_id
                    FROM tasker_data.dt_task_journal base
                    JOIN tasker_data.dt_task task
                        ON ( task.id = base.task_id )
                    JOIN tasker_data.st_task_category tc
                        ON ( tc.id = task.task_type_id )
                    WHERE base.id = a_id ) LOOP

                l_stats.activity_id := r.activity_id ;
                l_stats.object_id = r.object_id ;
                l_stats.object_owner_id := r.object_owner_id ;
                l_stats.parent_id := r.parent_id ;
                l_stats.parent_object_type := r.parent_object_type ;
                l_stats.parent_owner_id := r.parent_owner_id ;

            END LOOP ;

        ELSE

            FOR r IN (
                SELECT base.id AS object_id,
                        task.activity_id,
                        CASE
                            WHEN parent.id IS NULL THEN null::text
                            WHEN parent.id IS NOT DISTINCT FROM parent.activity_id THEN 'activity'
                            ELSE lower ( ptc.name )
                            END AS parent_object_type,
                        task.parent_id,
                        coalesce ( task.owner_id, task.created_by_id ) AS object_owner_id,
                        coalesce ( parent.owner_id, parent.created_by_id ) AS parent_owner_id,
                        task.assignee_id AS object_assignee_id,
                        parent.assignee_id AS parent_assignee_id
                    FROM tasker_data.dt_task task
                    LEFT JOIN tasker_data.dt_task parent
                        ON ( task.parent_id = parent.id )
                    LEFT JOIN tasker_data.st_task_category ptc
                        ON ( ptc.id = parent.task_type_id )
                    WHERE dt.id = a_id ) LOOP

                l_stats.activity_id := r.activity_id ;
                l_stats.object_assignee_id := r.object_assignee_id ;
                l_stats.object_id = r.object_id ;
                l_stats.object_owner_id := r.object_owner_id ;
                l_stats.parent_assignee_id := r.parent_assignee_id ;
                l_stats.parent_id := r.parent_id ;
                l_stats.parent_object_type := r.parent_object_type ;
                l_stats.parent_owner_id := r.parent_owner_id ;

            END LOOP ;

        END IF ;

    ELSIF a_parent_id IS NOT NULL THEN

        -- Assert that the parent ID specified is currently for a task of some
        -- form as users, profiles, and reference data do not have parents
        FOR r IN (
            SELECT task.id AS parent_id,
                    task.activity_id,
                    CASE
                        WHEN task.id = task.activity_id THEN 'activity'
                        ELSE lower ( ptc.name )
                        END AS parent_object_type,
                    coalesce ( task.owner_id, task.created_by_id ) AS parent_owner_id,
                    task.assignee_id AS parent_assignee_id
                FROM tasker_data.dt_task task
                LEFT JOIN tasker_data.st_task_category ptc
                    ON ( ptc.id = task.task_type_id )
                WHERE dt.id = a_parent_id ) LOOP

            l_stats.activity_id := r.activity_id ;
            l_stats.parent_id := r.parent_id ;
            l_stats.parent_object_type := r.parent_object_type ;
            l_stats.parent_owner_id := r.parent_owner_id ;
            l_stats.parent_assignee_id := r.parent_assignee_id ;

        END LOOP ;

    END IF ;

    ----------------------------------------------------------------------------
    -- Get the object type ID for the parent
    -- If the parent type hasn't been determined then default to the supplied type, if any
    FOR r IN (
        SELECT id,
                lower ( name ) AS object_type
            FROM tasker_data.st_object_type
            WHERE lower ( name ) = coalesce ( l_stats.parent_object_type, lower ( a_parent_object_type ) )
                AND is_enabled ) LOOP

        l_stats.parent_object_type_id := r.id ;

        IF l_stats.parent_object_type IS NULL THEN
            l_stats.parent_object_type := r.object_type ;
        END IF ;

    END LOOP ;

    IF l_stats.activity_id IS NOT NULL THEN

        FOR r IN (
            SELECT visibility_id,
                    visibility,
                    status_category,
                    owner_id
                FROM tasker.dv_activity
                WHERE dv_activity.id = l_stats.activity_id ) LOOP

            l_stats.activity_visibility_id := r.visibility_id ;
            l_stats.activity_visibility := r.visibility ;
            l_stats.status_category := r.status_category ;
            l_stats.activity_owner_id := r.owner_id ;

        END LOOP ;

    END IF ;


   -- object_type text,
   -- object_type_id integer,
   -- object_id integer,
   -- object_owner_id integer,
   -- object_assignee_id integer,
   -- ----
   -- parent_object_type text,
   -- parent_object_type_id integer,
   -- parent_id integer,
   -- parent_owner_id integer,
   -- parent_assignee_id integer ) ;

    RETURN l_stats ;

END ;
$$ ;

ALTER FUNCTION tasker.get_object_stats ( text, integer, text, integer ) OWNER TO tasker_owner ;

COMMENT ON FUNCTION tasker.get_object_stats ( text, integer, text, integer ) IS 'Returns the statistics for the specified object' ;
