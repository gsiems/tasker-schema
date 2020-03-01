-- support functions
\i tasker/function/user_id.sql

\i tasker/function/user_is_admin.sql
\i tasker/function/has_admin.sql

\i tasker/function/activity_is_parent_of.sql
\i tasker/function/task_comment_is_parent_of.sql
\i tasker/function/task_is_parent_of.sql
\i tasker/function/user_is_boss_of.sql

\i tasker/function/user_can_create_activity.sql
\i tasker/function/user_can_update_activity.sql
\i tasker/function/user_can_select_activity.sql
\i tasker/function/user_can_assign_activity.sql
\i tasker/function/user_can_delete_activity.sql
\i tasker/function/user_can_move_activity.sql

\i tasker/function/user_can_create_task.sql
\i tasker/function/user_can_select_task.sql
\i tasker/function/user_can_delete_task.sql
\i tasker/function/user_can_update_task.sql
\i tasker/function/user_can_update_task_status.sql
\i tasker/function/user_can_assign_task.sql
\i tasker/function/user_can_use_task.sql

\i tasker/function/user_can_move_task.sql
\i tasker/function/user_can_select_journal.sql

-- reference data functions
\i tasker/function/activity_category__delete.sql
\i tasker/function/activity_category__insert.sql
\i tasker/function/activity_category__update.sql

\i tasker/function/activity_status__delete.sql
\i tasker/function/activity_status__insert.sql
\i tasker/function/activity_status__update.sql

\i tasker/function/activity_attribute_type__delete.sql
\i tasker/function/activity_attribute_type__insert.sql
\i tasker/function/activity_attribute_type__update.sql

\i tasker/function/task_status__delete.sql
\i tasker/function/task_status__insert.sql
\i tasker/function/task_status__update.sql

\i tasker/function/task_type__delete.sql
\i tasker/function/task_type__insert.sql
\i tasker/function/task_type__update.sql

\i tasker/function/task_attribute_type__delete.sql
\i tasker/function/task_attribute_type__insert.sql
\i tasker/function/task_attribute_type__update.sql

-- data functions
\i tasker/function/user__delete.sql
\i tasker/function/user__insert.sql
\i tasker/function/user__update.sql
\i tasker/function/user__move.sql
\i tasker/function/user__list.sql
\i tasker/function/user__select.sql

\i tasker/function/user_password__set.sql
\i tasker/function/user_password__validate.sql

\i tasker/function/user_token__set.sql
\i tasker/function/user_token__request.sql
\i tasker/function/user_token__validate.sql

\i tasker/function/initialize_admin.sql

\i tasker/function/activity__delete.sql
\i tasker/function/activity__insert.sql
\i tasker/function/activity__update.sql
\i tasker/function/activity__move.sql
\i tasker/function/activity__user_filter.sql
\i tasker/function/activity_task_type.sql

\i tasker/function/activity_user__delete.sql
\i tasker/function/activity_user__upsert.sql

\i tasker/function/task__delete.sql
\i tasker/function/task__insert.sql
\i tasker/function/task__update.sql
\i tasker/function/task__move.sql
\i tasker/function/task__list.sql
\i tasker/function/task__select.sql
\i tasker/function/task__update_status.sql

\i tasker/function/task_user__delete.sql
\i tasker/function/task_user__insert.sql
\i tasker/function/task_user__set_list.sql

\i tasker/function/task_watcher__clear.sql
\i tasker/function/task_watcher__set.sql

\i tasker/function/task_comment__delete.sql
\i tasker/function/task_comment__insert.sql
\i tasker/function/task_comment__update.sql

\i tasker/function/task_dependency__delete.sql
\i tasker/function/task_dependency__insert.sql
\i tasker/function/task_dependency__set_list.sql
\i tasker/function/task_dependency__clear_list.sql

\i tasker/function/task_file__delete.sql
\i tasker/function/task_file__insert.sql
\i tasker/function/task_file__update.sql

\i tasker/function/task_journal__delete.sql
\i tasker/function/task_journal__insert.sql
\i tasker/function/task_journal__update.sql
\i tasker/function/task_journal__list.sql
\i tasker/function/task_journal__select.sql

-- stats__activity_task_by_priority (_activity_id integer)
-- stats__activity_task_by_status (_activity_id integer)
-- stats__activity_task_by_type (_activity_id integer)
-- stats__activity_time_by_task_priority (_activity_id integer, _start_date date, _end_date date )
-- stats__activity_time_by_task_type (_activity_id integer, _start_date date, _end_date date )
-- stats__activity_time_by_user (_activity_id integer, _start_date date, _end_date date )
-- stats__user_task_by_activity (_user_name character varying, _activity_id integer, _start_date date, _end_date date )
-- stats__user_task_by_priority (_user_name character varying, _activity_id integer, _start_date date, _end_date date )
-- stats__user_task_by_type (_user_name character varying, _activity_id integer, _start_date date, _end_date date )

-- advisory_lock__clear (
-- advisory_lock__set (
-- notification_userid__log (
-- notification_username__log (
