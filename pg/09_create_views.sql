-- system views
\i tasker/view/sv_markup_type.sql
\i tasker/view/sv_ranking.sql
\i tasker/view/sv_date_severity.sql
--\i tasker/view/sv_eav_attribute_datatype.sql
--\i tasker/view/sv_association_type.sql
\i tasker/view/sv_issue_probability.sql
\i tasker/view/sv_issue_severity.sql
\i tasker/view/sv_issue_workaround.sql
\i tasker/view/sv_permission.sql
\i tasker/view/sv_task_category.sql
\i tasker/view/sv_visibility.sql

-- reference views
\i tasker/view/rv_role.sql
\i tasker/view/rv_task_status.sql
\i tasker/view/rv_task_type.sql
--\i tasker/view/rv_task_category_status.sql
--\i tasker/view/rv_eav_attribute_type.sql
\i tasker/view/rv_task_attribute_type.sql

-- user data views
\i tasker/view/dv_user_cc.sql
\i tasker/view/dv_user.sql

-- task data views
\i tasker/view/dv_activity_tree.sql
\i tasker/view/dv_activity.sql
--\i tasker/view/dv_activity_user.sql
--\i tasker/view/dv_activity_attribute.sql
--\i tasker/view/dv_allowed_task_type.sql
\i tasker/view/dv_task_tree.sql
\i tasker/view/dv_task.sql
\i tasker/view/dv_task_association.sql
\i tasker/view/dv_task_attribute.sql
\i tasker/view/dv_task_user.sql
\i tasker/view/dv_task_comment_tree.sql
\i tasker/view/dv_task_comment.sql
\i tasker/view/dv_task_journal.sql
\i tasker/view/dv_task_file.sql

-- task specialization views
\i tasker/view/dv_issue.sql
\i tasker/view/dv_meeting.sql
