
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = true;
SET client_min_messages = warning;

CREATE ROLE tasker_user LOGIN
    PASSWORD 'tasker'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

COMMENT ON ROLE tasker_user IS 'Application user for tasker.' ;

CREATE ROLE tasker_owner NOLOGIN
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

COMMENT ON ROLE tasker_owner IS 'Ownership role for all tasker objects.' ;
