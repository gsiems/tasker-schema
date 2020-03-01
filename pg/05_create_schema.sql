
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = true;
SET client_min_messages = warning;

\connect tasker

CREATE SCHEMA tasker;

ALTER SCHEMA tasker OWNER TO tasker_owner;

COMMENT ON SCHEMA tasker IS 'Task tracker data';

SET search_path = tasker, pg_catalog;

REVOKE ALL ON SCHEMA tasker FROM PUBLIC;

GRANT USAGE ON SCHEMA tasker TO tasker_user;

ALTER DATABASE tasker
  SET search_path = tasker, public;

ALTER ROLE tasker_user IN DATABASE tasker
  SET search_path = tasker, public;

ALTER ROLE tasker_owner IN DATABASE tasker
  SET search_path = tasker, public;
