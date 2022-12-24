TRUNCATE TABLE tasker_data.dt_user CASCADE ;

SELECT setval ( pg_get_serial_sequence ( 'tasker_data.dt_user', 'id' ), 1 ) ;

-- Restore the public user
INSERT INTO tasker_data.dt_user (
        id,
        username,
        is_enabled )
    VALUES ( -1, 'public', false ) ;

-- Setup the testing user as admin
INSERT INTO tasker_data.dt_user (
        username,
        is_admin )
    SELECT current_user::text AS username,
            true ;

/*

WITH names AS (
    SELECT name
        FROM baby_names_2021
        GROUP BY name
        HAVING count (*) > 1
        ORDER BY name
),
positions AS (
    SELECT name
        FROM (
            VALUES
                ( 'Administrator' ),
                ( 'BA' ),
                ( 'Cxo' ),
                ( 'Developer' ),
                ( 'Manager' ),
                ( 'Observer' ),
                ( 'PM' ),
                ( 'Reporter' ),
                ( 'Supervisor' )
            ) AS dat ( name )
)
SELECT concat ( names.name, positions.name ) AS name
    FROM positions
    LEFT JOIN names
        ON ( substr ( names.name, 1, 1 ) = substr ( positions.name, 1, 1 ) ) ;

*/

INSERT INTO tasker_data.dt_user (
        username )
    VALUES
        ( 'AlexisAdministrator' ),
        ( 'ArielAdministrator' ),
        ( 'BaylorBA' ),
        ( 'BlakeBA' ),
        ( 'BriarBA' ),
        ( 'CameronCxo' ),
        ( 'DakotaDeveloper' ),
        ( 'DallasDeveloper' ),
        ( 'DenverDeveloper' ),
        ( 'DiorDeveloper' ),
        ( 'DrewDeveloper' ),
        ( 'DylanDeveloper' ),
        ( 'MicahManager' ),
        ( 'MilanManager' ),
        ( 'OakleyObserver' ),
        ( 'OceanObserver' ),
        ( 'PalmerPM' ),
        ( 'ParkerPM' ),
        ( 'RemingtonReporter' ),
        ( 'RileyReporter' ),
        ( 'RiverReporter' ),
        ( 'RobinReporter' ),
        ( 'RoryReporter' ),
        ( 'RowanReporter' ),
        ( 'SageSupervisor' ),
        ( 'SalemSupervisor' ),
        ( 'SawyerSupervisor' ),
        ( 'ShilohSupervisor' ),
        ( 'SkylerSupervisor' ),
        ( 'SuttonSupervisor' ) ;

--------------------------------------------------------------------------------
-- Populate the org chart data
-- Set supervisor_id for managers
WITH cxo AS (
    SELECT id
        FROM tasker_data.dt_user
        WHERE username ~ '^C'
)
UPDATE tasker_data.dt_user
    SET supervisor_id = cxo.id
    FROM cxo
    WHERE username ~ '^M' ;

-- Set supervisor_id for supervisors
WITH managers AS (
    SELECT row_number () OVER ( ORDER BY username ) AS rn,
            id,
            username
        FROM tasker_data.dt_user
        WHERE username ~ '^M'
),
mgr_count as (
    SELECT count (*) AS x
    FROM managers
),
supervisors AS (
    SELECT row_number () OVER ( ORDER BY username ) AS rn,
            id,
            username
        FROM tasker_data.dt_user
        WHERE username ~ '^S'
        ORDER by username
),
n AS (
    SELECT managers.id AS supervisor_id,
            supervisors.id
        FROM supervisors
        CROSS JOIN managers
        CROSS JOIN mgr_count
        WHERE managers.rn - 1 = mod ( supervisors.rn , mgr_count.x )
)
UPDATE tasker_data.dt_user o
    SET supervisor_id = n.supervisor_id
    FROM n
    WHERE o.id = n.id ;

-- Set supervisor_id for workers
WITH buckets AS (
    SELECT key,
            val
        FROM (
            VALUES
                ( 'A', 1 ),
                ( 'B', 2 ),
                ( 'D', 3 ),
                ( 'O', 4 ),
                ( 'P', 5 ),
                ( 'R', 6 )
            ) dat ( key, val )
),
users AS (
    SELECT id,
            username,
            buckets.val AS bucket
        FROM tasker_data.dt_user
        JOIN buckets
            ON ( buckets.key = substr ( username, 1, 1 ) )
        WHERE supervisor_id IS NULL
            AND username !~ '^C'
),
supervisors AS (
    SELECT row_number () OVER ( ORDER BY username ) AS rn,
            id,
            username
        FROM tasker_data.dt_user
        WHERE username ~ '^S'
        ORDER by username
),
n AS (
    SELECT supervisors.id AS supervisor_id,
            users.id
    FROM supervisors
    LEFT JOIN users
        ON ( users.bucket = supervisors.rn )
)
UPDATE tasker_data.dt_user o
    SET supervisor_id = n.supervisor_id
    FROM n
    WHERE o.id = n.id ;

--------------------------------------------------------------------------------
-- is_admin
UPDATE tasker_data.dt_user
    SET is_admin = true
    WHERE substr ( username, 1, 1 ) = 'A' ;
