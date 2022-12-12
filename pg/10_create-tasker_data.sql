
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = true;
SET client_min_messages = warning;

\connect tasker

\unset ON_ERROR_STOP

DROP SCHEMA IF EXISTS tasker_data CASCADE ;

CREATE SCHEMA IF NOT EXISTS tasker_data;

ALTER SCHEMA tasker_data OWNER TO tasker_owner;

COMMENT ON SCHEMA tasker_data IS 'Task tracker data';

REVOKE ALL ON SCHEMA tasker_data FROM PUBLIC;

GRANT USAGE ON SCHEMA tasker_data TO tasker_user;

\set ON_ERROR_STOP

-- Tables ----------------------------------------------------------------------
-- system tables
---- for setting priorities
\i tasker_data/table/st_ranking.sql
\i tasker_data/table/st_date_importance.sql
\i tasker_data/table/st_issue_probability.sql
\i tasker_data/table/st_issue_severity.sql
\i tasker_data/table/st_issue_workaround.sql

---- for managing access/permissions
\i tasker_data/table/st_visibility.sql
\i tasker_data/table/st_role.sql
\i tasker_data/table/st_object_type.sql
\i tasker_data/table/st_object_action.sql
\i tasker_data/table/st_object_permission.sql

---- other
\i tasker_data/table/st_markup_type.sql
--\i tasker_data/table/st_eav_attribute_datatype.sql
--\i tasker_data/table/st_permission.sql
\i tasker_data/table/st_association_type.sql
\i tasker_data/table/st_task_category.sql
\i tasker_data/table/st_open_category.sql



-- reference tables
--\i tasker_data/table/rt_role.sql
\i tasker_data/table/rt_task_status.sql
\i tasker_data/table/rt_task_type.sql
\i tasker_data/table/rt_task_category_status.sql
--\i tasker_data/table/rt_eav_attribute_type.sql
--\i tasker_data/table/rt_task_attribute_type.sql

-- user data tables
\i tasker_data/table/dt_user.sql
\i tasker_data/table/dt_user_password.sql
\i tasker_data/table/dt_user_token.sql

-- task data tables
\i tasker_data/table/dt_task.sql
\i tasker_data/table/dt_task_association.sql
--\i tasker_data/table/dt_task_attribute.sql
--\i tasker_data/table/dt_task_user.sql
\i tasker_data/table/dt_activity_member.sql

\i tasker_data/table/dt_task_comment.sql
\i tasker_data/table/dt_task_journal.sql
\i tasker_data/table/dt_task_file.sql

-- task specialization tables
\i tasker_data/table/dt_task_issue.sql
\i tasker_data/table/dt_task_meeting.sql

--------------------------------------------------------------------------------
REVOKE ALL ON ALL TABLES IN SCHEMA tasker_data FROM public ;
REVOKE ALL ON SCHEMA tasker_data FROM public ;
