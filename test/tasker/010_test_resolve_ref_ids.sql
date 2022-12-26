
\i 20_pre_tap.sql

-- Plan count should be the number of tests
SELECT plan ( 58 ) ;
--SELECT * FROM no_plan ( ) ;

SELECT ok (
    1::smallint = tasker.resolve_date_importance_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup date importance ID by ID (1)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_date_importance_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup date importance ID by ID as name (2)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_date_importance_id (
        a_id => null::smallint,
        a_name => 'Aspirational' ),
    'Lookup date importance ID by name (3)'
    ) ;
SELECT ok (
    tasker.resolve_date_importance_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup date importance ID for non-existent name fails (4)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_probability_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup issue probability ID by ID (5)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_probability_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup issue probability ID by ID as name (6)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_probability_id (
        a_id => null::smallint,
        a_name => 'Not applicable' ),
    'Lookup issue probability ID by name (7)'
    ) ;
SELECT ok (
    tasker.resolve_issue_probability_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup issue probability ID for non-existent name fails (8)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_severity_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup issue severity ID by ID (9)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_severity_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup issue severity ID by ID as name (10)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_severity_id (
        a_id => null::smallint,
        a_name => 'Trivial' ),
    'Lookup issue severity ID by name (11)'
    ) ;
SELECT ok (
    tasker.resolve_issue_severity_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup issue severity ID for non-existent name fails (12)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_workaround_id (
        a_id =>  1::smallint,
        a_name => null::text ),
    'Lookup issue workaround ID by ID (13)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_workaround_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup issue workaround ID by ID as name (14)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_issue_workaround_id (
        a_id => null::smallint,
        a_name => 'Not applicable' ),
    'Lookup issue workaround ID by name (15)'
    ) ;
SELECT ok (
    tasker.resolve_issue_workaround_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup issue workaround ID for non-existent name fails (16)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_markup_type_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup markup type ID by ID (17)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_markup_type_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup markup type ID by ID as name (18)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_markup_type_id (
        a_id => null::smallint,
        a_name => 'Plaintext' ),
    'Lookup markup type ID by name (19)'
    ) ;
SELECT ok (
    tasker.resolve_markup_type_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup markup type ID for non-existent name fails (20)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_action_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup object action ID by ID (21)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_action_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup object action ID by ID as name (22)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_action_id (
        a_id => null::smallint,
        a_name => 'Select' ),
    'Lookup object action ID by name (23)'
    ) ;
SELECT ok (
    tasker.resolve_object_action_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup object action ID for non-existent name fails (24)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_type_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup object type ID by ID (25)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_type_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup object type ID by ID as name (26)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_object_type_id (
        a_id => null::smallint,
        a_name => 'activity' ),
    'Lookup object type ID by name (27)'
    ) ;
SELECT ok (
    tasker.resolve_object_type_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup object type ID for non-existent name fails (28)'
    ) ;
SELECT ok (
    3::smallint = tasker.resolve_ranking_id (
        a_id => 3::smallint,
        a_name => null::text ),
    'Lookup ranking ID by ID (29)'
    ) ;
SELECT ok (
    3::smallint = tasker.resolve_ranking_id (
        a_id => null::smallint,
        a_name => 3::text ),
    'Lookup ranking ID by ID as name (30)'
    ) ;
SELECT ok (
    3::smallint = tasker.resolve_ranking_id (
        a_id => null::smallint,
        a_name => 'Low' ),
    'Lookup ranking ID by name (31)'
    ) ;
SELECT ok (
    tasker.resolve_ranking_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup ranking ID for non-existent name fails (32)'
    ) ;
SELECT ok (
    10::smallint = tasker.resolve_role_id (
        a_id => 10::smallint,
        a_name => null::text ),
    'Lookup role ID by ID (33)'
    ) ;
SELECT ok (
    10::smallint = tasker.resolve_role_id (
        a_id => null::smallint,
        a_name => 10::text ),
    'Lookup role ID by ID as name (34)'
    ) ;
SELECT ok (
    10::smallint = tasker.resolve_role_id (
        a_id => null::smallint,
        a_name => 'Observer' ),
    'Lookup role ID by name (35)'
    ) ;
SELECT ok (
    tasker.resolve_role_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup role ID for non-existent name fails (36)'
    ) ;
SELECT ok (
    2::smallint = tasker.resolve_status_category_id (
        a_id => 2::smallint,
        a_name => null::text ),
    'Lookup status category ID by ID (37)'
    ) ;
SELECT ok (
    2::smallint = tasker.resolve_status_category_id (
        a_id => null::smallint,
        a_name => 2::text ),
    'Lookup status category ID by ID as name (38)'
    ) ;
SELECT ok (
    2::smallint = tasker.resolve_status_category_id (
        a_id => null::smallint,
        a_name => 'Open' ),
    'Lookup status category ID by name (39)'
    ) ;
SELECT ok (
    tasker.resolve_status_category_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup status category ID for non-existent name fails (40)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_task_category_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup task category ID by ID (41)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_task_category_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup task category ID by ID as name (42)'
    ) ;
SELECT ok (
    1::smallint = tasker.resolve_task_category_id (
        a_id => null::smallint,
        a_name => 'Task' ),
    'Lookup task category ID by name (43)'
    ) ;
SELECT ok (
    tasker.resolve_task_category_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup task category ID for non-existent name fails (44)'
    ) ;
SELECT ok (
    1 = tasker.resolve_visibility_id (
        a_id => 1::smallint,
        a_name => null::text ),
    'Lookup visibility ID by ID (45)'
    ) ;
SELECT ok (
    1 = tasker.resolve_visibility_id (
        a_id => null::smallint,
        a_name => 1::text ),
    'Lookup visibility ID by ID as name (46)'
    ) ;
SELECT ok (
    1 = tasker.resolve_visibility_id (
        a_id => null::smallint,
        a_name => 'Public' ),
    'Lookup visibility ID by name (47)'
    ) ;
SELECT ok (
    tasker.resolve_visibility_id (
        a_id => null::smallint,
        a_name => 'no such value' )
     IS NULL,
    'Lookup visibility ID for non-existent name fails (48)'
    ) ;


SELECT ok (
    1::integer = tasker.resolve_task_status_id (
        a_id => 1::integer,
        a_name => null::text ),
    'Lookup task status ID by ID (49)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_status_id (
        a_id => null::integer,
        a_name => 1::text ),
    'Lookup task status ID by ID as name (50)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_status_id (
        a_id => null::integer,
        a_name => 'Pending' ),
    'Lookup task status ID by name (51)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_status_id (
        a_id => null::integer,
        a_name => 'no such value' )
     IS NULL,
    'Lookup task status ID for non-existent name fails (52)'
    ) ;

SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => 1::integer,
        a_name => null::text,
        a_type_category_id => null::smallint,
        a_type_category => null::text ),
    'Lookup task type ID by ID (53)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => null::integer,
        a_name => 1::text,
        a_type_category_id => 1::smallint,
        a_type_category => null::text ),
    'Lookup task type ID by ID as name (54)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => null::integer,
        a_name => 'Testing',
        a_type_category_id => 1::smallint,
        a_type_category => null::text ),
    'Lookup task type ID by name and category ID (55)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => null::integer,
        a_name => 'Testing',
        a_type_category_id => null::smallint,
        a_type_category => 'Task' ),
    'Lookup task type ID by name and category name (56)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => null::integer,
        a_name => 'Testing',
        a_type_category_id => null::smallint,
        a_type_category => null::text ),
    'Lookup task type ID by name (57)'
    ) ;
SELECT ok (
    1::integer = tasker.resolve_task_type_id (
        a_id => null::integer,
        a_name => 'no such value',
        a_type_category_id => null::smallint,
        a_type_category => null::text )
     IS NULL,
    'Lookup task type ID for non-existent name fails (58)'
    ) ;

\i 30_post_tap.sql
