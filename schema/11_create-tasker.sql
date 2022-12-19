
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = true;
SET client_min_messages = warning;

\connect tasker

\unset ON_ERROR_STOP

DROP SCHEMA IF EXISTS tasker CASCADE ;

CREATE SCHEMA tasker;

ALTER SCHEMA tasker OWNER TO tasker_owner;

COMMENT ON SCHEMA tasker IS 'Task tracker data';

REVOKE ALL ON SCHEMA tasker FROM PUBLIC;

GRANT USAGE ON SCHEMA tasker TO tasker_user;

\set ON_ERROR_STOP

-- Types -----------------------------------------------------------------------
--\i tasker/type/dml_ret.sql
\i tasker/type/ut_object_stats.sql
\i tasker/type/ut_user_stats.sql

-- Views -----------------------------------------------------------------------

-- system reference data views for setting priorities
\i tasker/view/sv_ranking.sql
\i tasker/view/sv_date_importance.sql
\i tasker/view/sv_issue_probability.sql
\i tasker/view/sv_issue_severity.sql
\i tasker/view/sv_issue_workaround.sql

-- system reference data views for managing access/permissions
\i tasker/view/sv_object_action.sql
\i tasker/view/sv_object_permission.sql
\i tasker/view/sv_object_type.sql
\i tasker/view/sv_role.sql
\i tasker/view/sv_visibility.sql

-- system reference data views for other
\i tasker/view/sv_association_type.sql
\i tasker/view/sv_markup_type.sql
\i tasker/view/sv_status_category.sql
\i tasker/view/sv_task_category.sql

-- reference views
--\i tasker/view/rv_role.sql
\i tasker/view/rv_task_status.sql
\i tasker/view/rv_task_type.sql
\i tasker/view/rv_task_category_status.sql
--\i tasker/view/rv_eav_attribute_type.sql
--\i tasker/view/rv_task_attribute_type.sql

-- user data views
\i tasker/view/dv_user_reporting_chain.sql
\i tasker/view/dv_user.sql

-- task data views
\i tasker/view/dv_activity_tree.sql
\i tasker/view/dv_activity.sql
\i tasker/view/dv_activity_member.sql

--\i tasker/view/dv_activity_user.sql
--\i tasker/view/dv_activity_attribute.sql
--\i tasker/view/dv_allowed_task_type.sql

\i tasker/view/dv_task_tree.sql
\i tasker/view/dv_task.sql

--\i tasker/view/dv_task_association.sql
--\i tasker/view/dv_task_attribute.sql
--\i tasker/view/dv_task_user.sql
--\i tasker/view/dv_task_comment_tree.sql
--\i tasker/view/dv_task_comment.sql
--\i tasker/view/dv_task_journal.sql
--\i tasker/view/dv_task_file.sql

-- task specialization views
--\i tasker/view/dv_issue.sql
--\i tasker/view/dv_meeting.sql

-- Functions -------------------------------------------------------------------

\i tasker/function/resolve_role_id.sql
\i tasker/function/resolve_user_id.sql
\i tasker/function/get_object_stats.sql
\i tasker/function/get_user_stats.sql

\i tasker/function/get_minimum_required_role.sql
\i tasker/function/has_permission.sql
\i tasker/function/is_system_admin.sql

\i tasker/function/can_do.sql


-- support functions
--\i tasker/function/user_id.sql

--\i tasker/function/user_is_admin.sql
--\i tasker/function/has_admin.sql

--\i tasker/function/activity_is_parent_of.sql
--\i tasker/function/task_comment_is_parent_of.sql
--\i tasker/function/task_is_parent_of.sql
--\i tasker/function/user_is_boss_of.sql

--\i tasker/function/user_can_create_activity.sql
--\i tasker/function/user_can_update_activity.sql
--\i tasker/function/user_can_select_activity.sql
--\i tasker/function/user_can_assign_activity.sql
--\i tasker/function/user_can_delete_activity.sql
--\i tasker/function/user_can_move_activity.sql

--\i tasker/function/user_can_create_task.sql
--\i tasker/function/user_can_select_task.sql
--\i tasker/function/user_can_delete_task.sql
--\i tasker/function/user_can_update_task.sql
--\i tasker/function/user_can_update_task_status.sql
--\i tasker/function/user_can_assign_task.sql
--\i tasker/function/user_can_use_task.sql

--\i tasker/function/user_can_move_task.sql
--\i tasker/function/user_can_select_journal.sql

-- reference data functions
--\i tasker/function/activity_category__delete.sql
--\i tasker/function/activity_category__insert.sql
--\i tasker/function/activity_category__update.sql

--\i tasker/function/activity_status__delete.sql
--\i tasker/function/activity_status__insert.sql
--\i tasker/function/activity_status__update.sql

--\i tasker/function/activity_attribute_type__delete.sql
--\i tasker/function/activity_attribute_type__insert.sql
--\i tasker/function/activity_attribute_type__update.sql

--\i tasker/function/task_status__delete.sql
--\i tasker/function/task_status__insert.sql
--\i tasker/function/task_status__update.sql

--\i tasker/function/task_type__delete.sql
--\i tasker/function/task_type__insert.sql
--\i tasker/function/task_type__update.sql

--\i tasker/function/task_attribute_type__delete.sql
--\i tasker/function/task_attribute_type__insert.sql
--\i tasker/function/task_attribute_type__update.sql

-- data functions
--\i tasker/function/user__delete.sql
--\i tasker/function/user__insert.sql
--\i tasker/function/user__update.sql
--\i tasker/function/user__move.sql
--\i tasker/function/user__list.sql
--\i tasker/function/user__select.sql

--\i tasker/function/user_password__set.sql
--\i tasker/function/user_password__validate.sql

--\i tasker/function/user_token__set.sql
--\i tasker/function/user_token__request.sql
--\i tasker/function/user_token__validate.sql

--\i tasker/function/initialize_admin.sql

--\i tasker/function/activity__delete.sql
--\i tasker/function/activity__insert.sql
--\i tasker/function/activity__update.sql
--\i tasker/function/activity__move.sql
--\i tasker/function/activity__user_filter.sql
--\i tasker/function/activity_task_type.sql

--\i tasker/function/activity_user__delete.sql
--\i tasker/function/activity_user__upsert.sql

--\i tasker/function/task__delete.sql
--\i tasker/function/task__insert.sql
--\i tasker/function/task__update.sql
--\i tasker/function/task__move.sql
--\i tasker/function/task__list.sql
--\i tasker/function/task__select.sql
--\i tasker/function/task__update_status.sql

--\i tasker/function/task_user__delete.sql
--\i tasker/function/task_user__insert.sql
--\i tasker/function/task_user__set_list.sql

--\i tasker/function/task_watcher__clear.sql
--\i tasker/function/task_watcher__set.sql

--\i tasker/function/task_comment__delete.sql
--\i tasker/function/task_comment__insert.sql
--\i tasker/function/task_comment__update.sql

--\i tasker/function/task_association__delete.sql
--\i tasker/function/task_association__insert.sql

--\i tasker/function/task_file__delete.sql
--\i tasker/function/task_file__insert.sql
--\i tasker/function/task_file__update.sql

--\i tasker/function/task_journal__delete.sql
--\i tasker/function/task_journal__insert.sql
--\i tasker/function/task_journal__update.sql
--\i tasker/function/task_journal__list.sql
--\i tasker/function/task_journal__select.sql

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



-- Procedures ------------------------------------------------------------------
