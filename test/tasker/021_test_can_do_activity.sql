
\i 20_pre_tap.sql

-- Plan count should be the number of tests
SELECT plan ( 168 ) ;
--SELECT * FROM no_plan ( ) ;

/*
Generate test cases using:

WITH act_one AS (
    SELECT dt.id AS rn,
            dt.parent_id,
            dt.activity_id,
            parent.activity_id AS parent_activity_id,
            dt.task_name,
            dt.owner_id,
            parent.owner_id AS parent_owner_id,
            lower ( split_part ( dt.task_name, ' ', 1 ) ) AS scope, -- a.k.a. visibility
            lower ( split_part ( parent.task_name, ' ', 1 ) ) AS parent_scope, -- a.k.a. visibility
            CASE
                WHEN lower ( dt.task_name ) ~ 'closed' THEN 'closed'
                WHEN lower ( dt.task_name ) ~ 'not open' THEN 'not open'
                ELSE 'open'
                END AS status,
            CASE
                WHEN lower ( parent.task_name ) ~ 'closed' THEN 'closed'
                WHEN lower ( parent.task_name ) ~ 'not open' THEN 'not open'
                ELSE 'open'
                END AS parent_status,
            min ( child.id ) AS child_id,
            lower ( soa.name ) AS action
        FROM tasker_data.dt_task dt
        LEFT JOIN tasker_data.dt_task parent
            ON ( parent.id = dt.parent_id
                AND parent.id = parent.activity_id )
        LEFT JOIN tasker_data.dt_task child
            ON ( child.parent_id = dt.id
                AND child.id = child.activity_id )
        CROSS JOIN tasker_data.st_object_action soa
        WHERE dt.id = dt.activity_id
            AND dt.task_name ~'^P'
            AND lower ( soa.name ) IN ( 'select', 'insert', 'delete', 'update' )
        GROUP BY dt.id,
            dt.activity_id,
            dt.task_name,
            dt.owner_id,
            parent.owner_id,
            parent.activity_id,
            parent.task_name,
            soa.name
),
act_two AS (
    SELECT -1::integer AS rn,
            null::integer AS parent_id,
            null::integer AS activity_id,
            null::integer AS parent_activity_id,
            'new activity' AS task_name,
            null::integer AS owner_id,
            null::integer AS parent_owner_id,
            'n/a'::text AS scope,
            'n/a'::text AS parent_scope,
            'n/a'::text AS status,
            'n/a'::text AS parent_status,
            null::integer AS child_id,
            'insert' AS action
),
act AS (
    SELECT *
        FROM act_one
    UNION
    SELECT *
        FROM act_two
),
--------------------------------------------------------------------------------
-- So, the thing is, for select, update, and delete we need an activity id and
-- the user association is to the activity
--
-- For inserts, the activity id is null, the parent id may or may not be null, and
-- the user association is to the parent (if any) or the user is an administrator
--------------------------------------------------------------------------------
act_user_object AS (
    SELECT act.rn,
            'public' AS username,
            'public' AS user_type
        FROM act
        WHERE act.parent_id IS NULL
    UNION
    SELECT act.rn,
            max ( usr.username ) AS username,
            'administrator' AS user_type
        FROM act
        CROSS JOIN tasker_data.dt_user usr
        WHERE usr.is_enabled
            AND usr.is_admin
            AND NOT EXISTS (
                SELECT dam.user_id
                    FROM tasker.dv_activity_member dam
                    WHERE dam.activity_id = act.activity_id
                        AND dam.user_id = usr.id )
            AND NOT EXISTS (
                SELECT dam.user_id
                    FROM tasker.dv_activity_member dam
                    WHERE dam.activity_id = act.parent_activity_id
                        AND dam.user_id = usr.id )
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            min ( dam.username ) AS username,
            'member' AS user_type
        FROM act
        JOIN tasker.dv_activity_member dam
            ON ( dam.activity_id = act.activity_id )
        WHERE dam.user_id <> act.owner_id           -- non-owner member
            AND dam.user_id <> act.parent_owner_id  -- non-parent-owner member
            AND role <> 'Manager'                   -- non-manager member
            AND act.action IN ( 'select', 'update', 'delete' )
            AND act.rn > 0
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            min ( dam.username ) AS username,
            'manager' AS user_type
        FROM act
        JOIN tasker.dv_activity_member dam
            ON ( dam.activity_id = act.activity_id )
        WHERE dam.user_id <> act.owner_id           -- non-owner member
            AND dam.user_id <> act.parent_owner_id  -- non-parent-owner member
            AND role = 'Manager'                    -- manager member
            AND act.action IN ( 'select', 'update', 'delete' )
            AND act.rn > 0
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            usr.username AS username,
            'owner' AS user_type
        FROM act
        JOIN tasker_data.dt_user usr
            ON ( usr.id = act.owner_id )
        WHERE act.action IN ( 'select', 'update', 'delete' )
            AND act.rn > 0
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            max ( usr.username ) AS username,
            'non-member' AS user_type
        FROM act
        CROSS JOIN tasker_data.dt_user usr
        WHERE usr.is_enabled
            AND NOT usr.is_admin
            AND NOT EXISTS (
                SELECT 1
                    FROM tasker_data.dt_activity_member dam
                    WHERE dam.user_id = usr.id )
        GROUP BY act.rn
),
act_user_parent AS (
    SELECT act.rn,
            'public' AS username,
            'public' AS user_type
        FROM act
        WHERE act.parent_id IS NULL
    UNION
    SELECT act.rn,
            max ( usr.username ) AS username,
            'administrator' AS user_type
        FROM act
        CROSS JOIN tasker_data.dt_user usr
        WHERE usr.is_enabled
            AND usr.is_admin
            AND NOT EXISTS (
                SELECT dam.user_id
                    FROM tasker.dv_activity_member dam
                    WHERE dam.activity_id = act.activity_id
                        AND dam.user_id = usr.id )
            AND NOT EXISTS (
                SELECT dam.user_id
                    FROM tasker.dv_activity_member dam
                    WHERE dam.activity_id = act.parent_activity_id
                        AND dam.user_id = usr.id )
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            min ( dam.username ) AS username,
            'member' AS user_type
        FROM act
        JOIN tasker.dv_activity_member dam
            ON ( dam.activity_id = act.parent_activity_id )
        WHERE dam.user_id <> act.owner_id           -- non-owner member
            AND dam.user_id <> act.parent_owner_id  -- non-parent-owner member
            AND role <> 'Manager'                   -- non-manager member
            AND act.action = 'insert'
            AND act.rn > 0
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            min ( dam.username ) AS username,
            'manager' AS user_type
        FROM act
        JOIN tasker.dv_activity_member dam
            ON ( dam.activity_id = act.parent_activity_id )
        WHERE dam.user_id <> act.owner_id           -- non-owner member
            AND dam.user_id <> act.parent_owner_id  -- non-parent-owner member
            AND role = 'Manager'                    -- manager member
            AND act.action = 'insert'
            AND act.rn > 0
        GROUP BY act.rn
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            usr.username AS username,
            'owner' AS user_type
        FROM act
        JOIN tasker_data.dt_user usr
            ON ( usr.id = act.parent_owner_id )
        WHERE act.action = 'insert'
            AND act.rn > 0
    ----------------------------------------------------------------------------
    UNION
    SELECT act.rn,
            max ( usr.username ) AS username,
            'non-member' AS user_type
        FROM act
        CROSS JOIN tasker_data.dt_user usr
        WHERE usr.is_enabled
            AND NOT usr.is_admin
            AND NOT EXISTS (
                SELECT 1
                    FROM tasker_data.dt_activity_member dam
                    WHERE dam.user_id = usr.id )
        GROUP BY act.rn
),
act_user AS (
    SELECT auo.rn,
            auo.user_type,
            auo.username AS object_username,
            aup.username AS parent_username
    FROM act_user_object auo
    LEFT JOIN act_user_parent aup
        ON ( aup.rn = auo.rn
            AND aup.user_type = auo.user_type )
),
base AS (
    SELECT act.scope,
            act.status,
            act.parent_status,
            act.action,
            CASE
                WHEN act.scope = 'n/a' AND act.parent_scope = 'n/a' AND act_user.user_type = 'non-member' THEN 'normal user'
                ELSE act_user.user_type
                END AS user_type,
            'a_object_type => ''activity''' AS a_object_type,
            'a_action => ' || quote_literal ( act.action ) AS a_action,
            CASE
                WHEN act_user.object_username IS NOT NULL THEN 'a_user => ' || quote_literal ( act_user.object_username )
                ELSE null::text
                END AS a_user,
            CASE
                WHEN act.rn < 0 THEN 'a_id => null::integer'
                WHEN act.action = 'insert' THEN 'a_id => null::integer'
                ELSE 'a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = ' || quote_literal ( act.task_name ) || ' )'
                END AS a_id,
            CASE
                WHEN act.parent_id IS NULL THEN 'a_parent_object_type => null::text'
                WHEN act.action = 'insert' THEN 'a_parent_object_type => ''activity'''
                ELSE 'a_parent_object_type => null::text'
                END AS a_parent_object_type,
            CASE
                WHEN act.parent_id IS NULL THEN 'a_parent_id => null::integer'
                WHEN act.action = 'insert' THEN 'a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = ' || quote_literal ( act.task_name ) || ' )'
                ELSE 'a_parent_id => null::integer'
                END AS a_parent_id,
            ( act.child_id IS NOT NULL ) AS has_children
        FROM act
        JOIN act_user
            ON act_user.rn = act.rn
),
x AS (
    SELECT  base.scope,
            base.status,
            base.parent_status,
            base.action,
            base.user_type,
            base.a_user,
            base.a_action,
            base.a_object_type,
            base.a_id,
            base.a_parent_object_type,
            base.a_parent_id,
            base.has_children,
            CASE
                WHEN base.action <> 'insert' AND a_id = 'a_id => null::integer' THEN false  -- non-inserts need an id
                --
                WHEN base.action = 'select' AND base.scope = 'public' THEN true             -- everyone can select public activities
                WHEN base.action = 'select' AND base.user_type = 'public' THEN false        -- public users can only select public activities, nothing else
                WHEN base.action = 'select' AND base.user_type = 'owner' THEN true          -- owners can select protected and their own private activities
                WHEN base.action = 'select' AND base.user_type = 'manager' THEN true        -- managers can select protected and their own private activities
                WHEN base.action = 'select' AND base.user_type = 'member' THEN true         -- members can select protected and their own private activities
                WHEN base.action = 'select' AND base.user_type = 'administrator' THEN true  -- administrators can select protected and private activities
                WHEN base.action = 'select' AND base.scope = 'private' THEN false           -- non-members cannot select private activities
                WHEN base.action = 'select' AND base.scope = 'protected' THEN true          -- non-public users can select protected activities
                WHEN base.action = 'select' THEN true
                --
                WHEN base.action = 'insert' AND base.user_type = 'public' THEN false        -- public users can only select public activities, nothing else
                --WHEN base.action = 'insert' AND base.parent_status <> 'open' THEN false     -- no-one can insert into a non-open activity
                WHEN base.action = 'insert' AND base.status NOT IN ( 'n/a', 'open' ) THEN false -- no-one can insert into a non-open activity
                WHEN base.action = 'insert' AND base.user_type = 'owner' THEN true          -- owners can insert sub-activities
                WHEN base.action = 'insert' AND base.user_type = 'administrator' THEN true  -- administrators can insert activities
                --
                WHEN base.action = 'update' AND base.user_type = 'public' THEN false        -- public users can only select public activities, nothing else
                WHEN base.action = 'update' AND base.user_type = 'owner' THEN true          -- owners can update activities
                WHEN base.action = 'update' AND base.user_type = 'manager' THEN true        -- managers can update activities
                WHEN base.action = 'update' AND base.user_type = 'administrator' THEN true  -- administrators can update activities
                --
                WHEN base.action = 'delete' AND base.has_children THEN false                -- no-one can delete populated activities
                WHEN base.action = 'delete' AND base.user_type = 'administrator' THEN true  -- administrators can delete activities
                WHEN base.action = 'delete' AND base.user_type = 'owner' THEN true          -- owners can delete activities
                --
                ELSE false
                END AS should_pass
        FROM base
        WHERE base.a_user IS NOT NULL
            AND ( base.a_id <> 'a_id => null::integer'
                OR ( base.a_id = 'a_id => null::integer'
                    AND base.action = 'insert' ) )
),
y AS (
    SELECT x.scope,
            x.status,
            x.parent_status,
            x.action,
            x.user_type,
            x.has_children,
            CASE
                WHEN should_pass
                    THEN concat_ws ( ' ', quote_ident ( initcap ( user_type ) ), 'user', 'can', action )
                ELSE concat_ws ( ' ', quote_ident ( initcap ( user_type ) ), 'user', 'cannot', action )
                END AS desc_preamble,
            CASE
                WHEN should_pass THEN E'SELECT ok (\n    tasker.can_do (\n'
                ELSE E'SELECT ok (\n    NOT tasker.can_do (\n'
                END
                || '        ' || concat_ws ( E',\n        ', x.a_user, x.a_action, x.a_object_type, x.a_id, x.a_parent_object_type, x.a_parent_id ) || E' ),\n' AS fcn
        FROM x
),
z AS (
    SELECT fcn,
            CASE
                WHEN action = 'delete' AND has_children
                    THEN concat_ws ( ' ', desc_preamble, status, scope, 'activity (has children)' )
                WHEN action <> 'insert'
                    THEN concat_ws ( ' ', desc_preamble, status, scope, 'activity' )
                WHEN action = 'insert' AND status = 'n/a' THEN
                    concat_ws ( ' ', desc_preamble, 'top-level activity' )
                ELSE --  action = 'insert'
                    concat_ws ( ' ', desc_preamble, 'activity into', status, scope, 'activity (parent is ' || parent_status || ')' )
                END AS description
        FROM y
),
z2 AS (
    SELECT min ( fcn ) AS fcn,
            description
        FROM z
        GROUP BY description
        ORDER BY description
)
SELECT fcn
        || '    ''' || description || ' ('  || ( row_number () over () )::text || E')''\n    ) ;' AS test
    FROM z2 ;

*/

SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete closed private activity (1)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete closed protected activity (2)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete closed public activity (3)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete not open private activity (4)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete not open protected activity (5)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete not open public activity (6)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete open private activity (7)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete open protected activity (8)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can delete open public activity (9)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ) ),
    '"Administrator" user can insert activity into open private activity (parent is open) (10)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ) ),
    '"Administrator" user can insert activity into open protected activity (parent is open) (11)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ) ),
    '"Administrator" user can insert activity into open public activity (parent is open) (12)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can insert top-level activity (13)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user cannot delete open private activity (has children) (14)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user cannot delete open protected activity (has children) (15)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user cannot delete open public activity (has children) (16)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ) ),
    '"Administrator" user cannot insert activity into closed private activity (parent is open) (17)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ) ),
    '"Administrator" user cannot insert activity into closed protected activity (parent is open) (18)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ) ),
    '"Administrator" user cannot insert activity into closed public activity (parent is open) (19)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ) ),
    '"Administrator" user cannot insert activity into not open private activity (parent is open) (20)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ) ),
    '"Administrator" user cannot insert activity into not open protected activity (parent is open) (21)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ) ),
    '"Administrator" user cannot insert activity into not open public activity (parent is open) (22)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select closed private activity (23)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select closed protected activity (24)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select closed public activity (25)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select not open private activity (26)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select not open protected activity (27)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select not open public activity (28)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select open private activity (29)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select open protected activity (30)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can select open public activity (31)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update closed private activity (32)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update closed protected activity (33)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update closed public activity (34)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update not open private activity (35)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update not open protected activity (36)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update not open public activity (37)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update open private activity (38)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update open protected activity (39)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'ArielAdministrator',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Administrator" user can update open public activity (40)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete closed private activity (41)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete closed protected activity (42)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete closed public activity (43)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete not open private activity (44)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete not open protected activity (45)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete not open public activity (46)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete open private activity (47)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete open protected activity (48)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot delete open public activity (49)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ) ),
    '"Member" user cannot insert activity into closed private activity (parent is open) (50)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ) ),
    '"Member" user cannot insert activity into closed protected activity (parent is open) (51)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ) ),
    '"Member" user cannot insert activity into closed public activity (parent is open) (52)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ) ),
    '"Member" user cannot insert activity into not open private activity (parent is open) (53)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ) ),
    '"Member" user cannot insert activity into not open protected activity (parent is open) (54)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ) ),
    '"Member" user cannot insert activity into not open public activity (parent is open) (55)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ) ),
    '"Member" user cannot insert activity into open private activity (parent is open) (56)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ) ),
    '"Member" user cannot insert activity into open protected activity (parent is open) (57)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ) ),
    '"Member" user cannot insert activity into open public activity (parent is open) (58)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update closed private activity (59)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update closed protected activity (60)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update closed public activity (61)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update not open private activity (62)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update not open protected activity (63)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update not open public activity (64)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update open private activity (65)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update open protected activity (66)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user cannot update open public activity (67)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select closed private activity (68)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select closed protected activity (69)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select closed public activity (70)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select not open private activity (71)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select not open protected activity (72)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select not open public activity (73)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select open private activity (74)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select open protected activity (75)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'BaylorBA',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Member" user can select open public activity (76)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete closed private activity (77)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete closed protected activity (78)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete closed public activity (79)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete not open private activity (80)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete not open protected activity (81)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete not open public activity (82)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open private activity (83)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open private activity (has children) (84)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open protected activity (85)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open protected activity (has children) (86)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open public activity (87)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot delete open public activity (has children) (88)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ) ),
    '"Non-Member" user cannot insert activity into closed private activity (parent is open) (89)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ) ),
    '"Non-Member" user cannot insert activity into closed protected activity (parent is open) (90)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ) ),
    '"Non-Member" user cannot insert activity into closed public activity (parent is open) (91)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ) ),
    '"Non-Member" user cannot insert activity into not open private activity (parent is open) (92)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ) ),
    '"Non-Member" user cannot insert activity into not open protected activity (parent is open) (93)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ) ),
    '"Non-Member" user cannot insert activity into not open public activity (parent is open) (94)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ) ),
    '"Non-Member" user cannot insert activity into open private activity (parent is open) (95)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ) ),
    '"Non-Member" user cannot insert activity into open protected activity (parent is open) (96)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ) ),
    '"Non-Member" user cannot insert activity into open public activity (parent is open) (97)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot select closed private activity (98)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot select not open private activity (99)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot select open private activity (100)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update closed private activity (101)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update closed protected activity (102)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update closed public activity (103)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update not open private activity (104)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update not open protected activity (105)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update not open public activity (106)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update open private activity (107)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update open protected activity (108)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user cannot update open public activity (109)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select closed protected activity (110)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select closed public activity (111)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select not open protected activity (112)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select not open public activity (113)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select open protected activity (114)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Non-Member" user can select open public activity (115)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SuttonSupervisor',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Normal User" user cannot insert top-level activity (116)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete closed private activity (117)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete closed protected activity (118)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete closed public activity (119)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete not open private activity (120)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete not open protected activity (121)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete not open public activity (122)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete open private activity (123)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete open protected activity (124)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can delete open public activity (125)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ) ),
    '"Owner" user can insert activity into open private activity (parent is open) (126)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ) ),
    '"Owner" user can insert activity into open protected activity (parent is open) (127)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ) ),
    '"Owner" user can insert activity into open public activity (parent is open) (128)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SkylerSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user cannot delete open private activity (has children) (129)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SkylerSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user cannot delete open protected activity (has children) (130)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'SkylerSupervisor',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user cannot delete open public activity (has children) (131)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ) ),
    '"Owner" user cannot insert activity into closed private activity (parent is open) (132)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ) ),
    '"Owner" user cannot insert activity into closed protected activity (parent is open) (133)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ) ),
    '"Owner" user cannot insert activity into closed public activity (parent is open) (134)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ) ),
    '"Owner" user cannot insert activity into not open private activity (parent is open) (135)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ) ),
    '"Owner" user cannot insert activity into not open protected activity (parent is open) (136)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => 'activity',
        a_parent_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ) ),
    '"Owner" user cannot insert activity into not open public activity (parent is open) (137)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select closed private activity (138)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select closed protected activity (139)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select closed public activity (140)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select not open private activity (141)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select not open protected activity (142)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select not open public activity (143)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select open private activity (144)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select open protected activity (145)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can select open public activity (146)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update closed private activity (147)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update closed protected activity (148)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Closed)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update closed public activity (149)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update not open private activity (150)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update not open protected activity (151)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Not Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update not open public activity (152)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update open private activity (153)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update open protected activity (154)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'PalmerPM',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity (Open)' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Owner" user can update open public activity (155)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot delete open private activity (has children) (156)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot delete open protected activity (has children) (157)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'delete',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot delete open public activity (has children) (158)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot insert activity into open private activity (parent is open) (159)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot insert activity into open protected activity (parent is open) (160)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot insert activity into open public activity (parent is open) (161)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'insert',
        a_object_type => 'activity',
        a_id => null::integer,
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot insert top-level activity (162)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot select open private activity (163)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot select open protected activity (164)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Private activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot update open private activity (165)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Protected activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot update open protected activity (166)'
    ) ;
SELECT ok (
    NOT tasker.can_do (
        a_user => 'public',
        a_action => 'update',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user cannot update open public activity (167)'
    ) ;
SELECT ok (
    tasker.can_do (
        a_user => 'public',
        a_action => 'select',
        a_object_type => 'activity',
        a_id => ( SELECT id FROM tasker_data.dt_task WHERE id = activity_id AND task_name = 'Public activity' ),
        a_parent_object_type => null::text,
        a_parent_id => null::integer ),
    '"Public" user can select open public activity (168)'
    ) ;

\i 30_post_tap.sql
