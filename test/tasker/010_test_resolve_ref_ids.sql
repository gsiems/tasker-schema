
\i 20_pre_tap.sql

-- Plan count should be the number of tests
SELECT plan ( 4 ) ;
--SELECT * FROM no_plan ( ) ;

/*
10	Observer
20	Reporter
30	Member
40	Analyst
50	Manager
60	Activity Owner
*/

SELECT ok (
    10 = tasker.resolve_role_id (
        a_name => 'Observer' ),
    'Lookup role ID by name'
    ) ;

SELECT ok (
    20 = tasker.resolve_role_id (
        a_id => 20::smallint ),
    'Lookup role ID by ID'
    ) ;

SELECT ok (
    30 = tasker.resolve_role_id (
        a_name => '30' ),
    'Lookup role ID by ID as name'
    ) ;

SELECT ok (
    tasker.resolve_role_id (
        a_name => 'no such' ) IS NULL,
    'Lookup ID for non-existent role fails'
    ) ;

\i 30_post_tap.sql
