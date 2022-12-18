
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = true;
SET client_min_messages = warning;

CREATE DATABASE tasker
    WITH TEMPLATE = template0
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

ALTER DATABASE tasker OWNER TO postgres;

\connect tasker

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog ;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA pg_catalog ;

REVOKE ALL ON DATABASE tasker FROM PUBLIC ;
GRANT CONNECT ON DATABASE tasker TO tasker_user ;
