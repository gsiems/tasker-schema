
\c tasker

CREATE SCHEMA IF NOT EXISTS tap ;

COMMENT ON SCHEMA tap IS 'Schema for pgTap objects' ;

CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA tap ;

CREATE SCHEMA IF NOT EXISTS test ;

--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA core TO session_user ;
