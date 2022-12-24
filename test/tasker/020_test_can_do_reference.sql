
\i 20_pre_tap.sql

-- Plan count should be the number of tests
SELECT plan ( 16 ) ;
--SELECT * FROM no_plan ( ) ;

/*
CREATE OR REPLACE FUNCTION tasker.can_do (
    a_user => xyz,
    a_action => xyz,
    a_object_type => xyz,
    a_id => xyz,
    a_parent_object_type => xyz,
    a_parent_id => xyz ) ;

*/

-- For convenience, clarity, and to minimize errors we're going to create a cache of the user IDs to use
CREATE TEMPORARY TABLE test_user_ids (
    id integer,
    username text,
    user_type text ) ;

INSERT INTO test_user_ids (
        id,
        user_type )
    SELECT id,
            'public'
        FROM tasker_data.dt_user
        WHERE username = 'public' ;

INSERT INTO test_user_ids (
        id,
        user_type )
    VALUES ( null::integer,
            'unknown' ) ;

WITH n AS (
    SELECT min ( id ) AS id
        FROM tasker_data.dt_user
        --WHERE NOT is_admin AND NOT can_create_activities AND is_enabled
        WHERE NOT is_admin AND is_enabled
),
disabled AS (
    UPDATE tasker_data.dt_user o
        SET is_enabled = false
        FROM n
        WHERE o.id = n.id
)
INSERT INTO test_user_ids (
        id,
        user_type )
    SELECT id,
            'disabled'
        FROM n ;

INSERT INTO test_user_ids (
        id,
        user_type )
    SELECT max ( id ),
            'regular'
        FROM tasker_data.dt_user
    --WHERE NOT is_admin AND NOT can_create_activities AND is_enabled ;
    WHERE NOT is_admin AND is_enabled ;

INSERT INTO test_user_ids (
        id,
        user_type )
    SELECT max ( id ),
            'admin'
        FROM tasker_data.dt_user
    WHERE is_admin ;

INSERT INTO test_user_ids (
        id,
        user_type )
    SELECT max ( id ),
            'activity'
        FROM tasker_data.dt_user
    --WHERE NOT is_admin AND can_create_activities ;
    WHERE NOT is_admin ;

--INSERT INTO test_user_ids (
--        id,
--        user_type )
--    SELECT max ( id ) AS id,
--            'regular'
--        FROM tasker_data.dt_user
--    WHERE NOT is_admin AND NOT can_create_activities AND is_enabled ;
--
--INSERT INTO test_user_ids (
--        id,
--        user_type )
--    SELECT id,
--            'public'
--        FROM tasker_data.dt_user
--    WHERE username = 'public' ;

UPDATE test_user_ids o
    SET username = n.username
    FROM tasker_data.dt_user n
    WHERE n.id = o.id ;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--SELECT user_type,
--        id,
--        username
--    FROM test_user_ids
--    ORDER BY user_type ;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Reference data
-- unknown user
SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='unknown' ),
        a_action => 'select',
        a_object_type => 'reference' ),
    'Unknown user cannot select reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='unknown' ),
        a_action => 'insert',
        a_object_type => 'reference' ),
    'Unknown user cannot insert reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='unknown' ),
        a_action => 'update',
        a_object_type => 'reference' ),
    'Unknown user cannot update reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='unknown' ),
        a_action => 'delete',
        a_object_type => 'reference' ),
    'Unknown user cannot delete reference data'
    ) ;

-- public user
SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='public' ),
        a_action => 'select',
        a_object_type => 'reference' ),
    'Public user cannot select reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='public' ),
        a_action => 'insert',
        a_object_type => 'reference' ),
    'Public user cannot insert reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='public' ),
        a_action => 'update',
        a_object_type => 'reference' ),
    'Public user cannot update reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='public' ),
        a_action => 'delete',
        a_object_type => 'reference' ),
    'Public user cannot delete reference data'
    ) ;

-- "regular" user
SELECT ok (
    tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='regular' ),
        a_action => 'select',
        a_object_type => 'reference' ),
    'Regular user can select reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='regular' ),
        a_action => 'insert',
        a_object_type => 'reference' ),
    'Regular user cannot insert reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='regular' ),
        a_action => 'update',
        a_object_type => 'reference' ),
    'Regular user cannot update reference data'
    ) ;

SELECT ok (
    NOT tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='regular' ),
        a_action => 'delete',
        a_object_type => 'reference' ),
    'Regular user cannot delete reference data'
    ) ;

-- "admin" user
SELECT ok (
    tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='admin' ),
        a_action => 'select',
        a_object_type => 'reference' ),
    'System Administrator can select reference data'
    ) ;

SELECT ok (
    tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='admin' ),
        a_action => 'insert',
        a_object_type => 'reference' ),
    'System Administrator can insert reference data'
    ) ;

SELECT ok (
    tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='admin' ),
        a_action => 'update',
        a_object_type => 'reference' ),
    'System Administrator can update reference data'
    ) ;

SELECT ok (
    tasker.can_do (
        a_user => ( SELECT username FROM test_user_ids WHERE user_type ='admin' ),
        a_action => 'delete',
        a_object_type => 'reference' ),
    'System Administrator can delete reference data'
    ) ;

\i 30_post_tap.sql
