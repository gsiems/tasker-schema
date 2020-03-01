-- system tables
\i tasker/table/st_markup_type.sql
\i tasker/table/st_ranking.sql
\i tasker/table/st_role.sql
\i tasker/table/st_date_severity.sql
\i tasker/table/st_task_category.sql
\i tasker/table/st_visibility.sql
\i tasker/table/st_issue_probability.sql
\i tasker/table/st_issue_severity.sql
\i tasker/table/st_issue_workaround.sql

-- reference tables
\i tasker/table/rt_activity_status.sql
\i tasker/table/rt_activity_category.sql
\i tasker/table/rt_activity_attribute_type.sql
\i tasker/table/rt_task_status.sql
\i tasker/table/rt_task_type.sql
\i tasker/table/rt_task_attribute_type.sql

-- user data tables
\i tasker/table/dt_user.sql
\i tasker/table/dt_user_password.sql
\i tasker/table/dt_user_token.sql

-- activity data tables
\i tasker/table/dt_activity.sql
\i tasker/table/dt_activity_user.sql
\i tasker/table/dt_allowed_task_type.sql
\i tasker/table/dt_activity_attribute.sql

-- task data tables
\i tasker/table/dt_task.sql
\i tasker/table/dt_task_attribute.sql
\i tasker/table/dt_task_dependency.sql
\i tasker/table/dt_task_user.sql
\i tasker/table/dt_task_watcher.sql
\i tasker/table/dt_task_comment.sql
\i tasker/table/dt_task_journal.sql
\i tasker/table/dt_task_file.sql

-- task specialization tables
\i tasker/table/dt_task_regular.sql
\i tasker/table/dt_task_requirement.sql
\i tasker/table/dt_task_issue.sql
\i tasker/table/dt_task_meeting.sql
