
-- Intended for sunning/troubleshooting individual tests

\i 10_init_testrun.sql
\i 20_pre_tap.sql

SELECT plan ( 1 ) ;

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

\i 30_post_tap.sql
\i 40_finalize_testrun.sql
