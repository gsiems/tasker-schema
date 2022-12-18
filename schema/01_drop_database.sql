\c postgres

-- REVOKE CONNECT ON tasker FROM tasker_user ;

-- Ensure that there are no other connections to the database
SELECT pg_terminate_backend( pid )
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid( )
        AND datname = 'tasker';

DROP DATABASE IF EXISTS tasker;
