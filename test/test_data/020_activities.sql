TRUNCATE TABLE tasker_data.dt_task CASCADE ;

SELECT setval ( pg_get_serial_sequence ( 'tasker_data.dt_task', 'id' ), 1 ) ;

-- Some top-level activities
-- One for each level of visibility
WITH task_type AS (
    SELECT rtt.id AS task_type_id
        FROM tasker_data.rt_task_type rtt
        JOIN tasker_data.st_task_category stc
            ON ( rtt.category_id = stc.id )
        WHERE stc.name = 'Activity'
            AND rtt.name = 'Default'
),
stat AS (
    SELECT min ( rts.id ) AS status_id
        FROM tasker_data.rt_task_status rts
        JOIN tasker_data.st_status_category ssc
            ON ( ssc.id = rts.status_category_id )
        WHERE ssc.name = 'Open'
),
ownr AS (
    SELECT min ( supervisor_id ) AS owner_id
        FROM tasker_data.dt_user
        WHERE is_enabled
            AND NOT is_admin
            AND username ~ 'PM$'
),
tla AS (
    SELECT nextval ( pg_get_serial_sequence ( 'tasker_data.dt_task', 'id' ) ) AS id,
            sv.name || ' activity' AS task_name,
            ownr.owner_id,
            task_type.task_type_id,
            stat.status_id,
            sv.id AS visibility_id
        FROM task_type
        CROSS JOIN ownr
        CROSS JOIN stat
        CROSS JOIN tasker_data.st_visibility sv
),
usrol AS (
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        JOIN tasker_data.st_role rol
            ON ( usr.username LIKE '%' || rol.name )
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND rol.name IN ( 'Reporter', 'Observer' )
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'Developer$'
            AND rol.name = 'Member'
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'BA$'
            AND rol.name = 'Analyst'
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'PM$'
            AND rol.name = 'Manager'
        GROUP BY rol.id
    UNION
    SELECT ownr.owner_id AS user_id,
            rol.id AS role_id
        FROM ownr
        CROSS JOIN tasker_data.st_role rol
        WHERE rol.is_enabled
            AND rol.name = 'Activity Owner'
),
members as (
    SELECT user_id,
            min ( role_id ) AS role_id
        FROM usrol
        GROUP BY user_id
),
new_tasks AS (
    INSERT INTO tasker_data.dt_task (
            id,
            activity_id,
            task_name,
            owner_id,
            task_type_id,
            status_id,
            visibility_id )
        SELECT id,
                id,
                task_name,
                owner_id,
                task_type_id,
                status_id,
                visibility_id
            FROM tla
)
INSERT INTO tasker_data.dt_activity_member (
        activity_id,
        user_id,
        role_id )
    SELECT tla.id AS activity_id,
            members.user_id,
            members.role_id
        FROM tla
        CROSS JOIN members ;


--------------------------------------------------------------------------------
/*


                            Table "tasker_data.dt_activity_member"
    Column     |           Type           | Collation | Nullable |           Default
---------------+--------------------------+-----------+----------+------------------------------
 id            | integer                  |           | not null | generated always as identity
 activity_id   | integer                  |           | not null |
 user_id       | integer                  |           | not null |
 role_id       | smallint                 |           | not null |

*/


-- Some second-level activities
-- One per top level activity for each level of status category
WITH pact AS (
    SELECT dt.id AS parent_id,
            dt.owner_id,
            dt.task_type_id,
            dt.task_name,
            dt.visibility_id
        FROM tasker_data.dt_task dt
        WHERE dt.parent_id IS NULL
            AND dt.id = dt.activity_id
),
stat_type AS (
    SELECT rts.status_category,
            min ( rts.id ) AS status_id
        FROM tasker.rv_task_status rts
        WHERE rts.is_enabled
        GROUP BY rts.status_category
),
ownr AS (
    SELECT pact.parent_id,
            min ( usr.id ) AS owner_id
        FROM tasker_data.dt_user usr
        JOIN pact
            ON ( usr.supervisor_id = pact.owner_id )
        GROUP BY pact.parent_id
),
sla AS (
    SELECT nextval ( pg_get_serial_sequence ( 'tasker_data.dt_task', 'id'  ) ) AS id,
            pact.parent_id,
            pact.task_name || ' (' || stat_type.status_category || ')' AS task_name,
            ownr.owner_id,
            pact.task_type_id,
            stat_type.status_id,
            pact.visibility_id
        FROM pact
        JOIN ownr
            ON ( ownr.parent_id = pact.parent_id )
        CROSS JOIN stat_type
),
usrol AS (
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        JOIN tasker_data.st_role rol
            ON ( usr.username LIKE '%' || rol.name )
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND rol.name IN ( 'Reporter', 'Observer' )
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'Developer$'
            AND rol.name = 'Member'
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'BA$'
            AND rol.name = 'Analyst'
        GROUP BY rol.id
    UNION
    SELECT min ( usr.id ) AS user_id,
            rol.id AS role_id
        FROM tasker_data.dt_user usr
        CROSS JOIN tasker_data.st_role rol
        WHERE usr.is_enabled
            AND rol.is_enabled
            AND usr.username ~ 'PM$'
            AND rol.name = 'Manager'
        GROUP BY rol.id
    UNION
    SELECT ownr.owner_id AS user_id,
            rol.id AS role_id
        FROM ownr
        CROSS JOIN tasker_data.st_role rol
        WHERE rol.is_enabled
            AND rol.name = 'Activity Owner'
),
members as (
    SELECT user_id,
            min ( role_id ) AS role_id
        FROM usrol
        GROUP BY user_id
),
new_tasks AS (
    INSERT INTO tasker_data.dt_task (
            id,
            parent_id,
            activity_id,
            task_name,
            owner_id,
            task_type_id,
            status_id,
            visibility_id )
        SELECT id,
                parent_id,
                id,
                task_name,
                owner_id,
                task_type_id,
                status_id,
                visibility_id
            FROM sla
)
INSERT INTO tasker_data.dt_activity_member (
        activity_id,
        user_id,
        role_id )
    SELECT sla.id AS activity_id,
            members.user_id,
            members.role_id
        FROM sla
        CROSS JOIN members ;
