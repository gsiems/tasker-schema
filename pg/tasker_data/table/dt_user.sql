/*

Note the use of an ID column as the primary key so that it should be
possible to support users changing their usernames.

*/
CREATE TABLE tasker_data.dt_user (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    last_login timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    edition integer DEFAULT 0 NOT NULL,
    reports_to integer,
    created_by_id integer,
    updated_by_id integer,
    email_is_enabled boolean DEFAULT true NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    username character varying ( 32 ) NOT NULL,
    full_name character varying ( 128 ) NOT NULL,
    email_address character varying ( 320 ),
    CONSTRAINT dt_user_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_user_ux01 UNIQUE ( username ) ) ;

ALTER TABLE tasker_data.dt_user OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_user IS 'Tasker user accounts.' ;

COMMENT ON COLUMN tasker_data.dt_user.id IS 'Unique ID for the user account.' ;

COMMENT ON COLUMN tasker_data.dt_user.reports_to IS 'The ID of the supervisor user (if any). If the user has multiple bosses then choose the best one.' ;

COMMENT ON COLUMN tasker_data.dt_user.edition IS 'Indicates the number of edits made to the user record. Intended for use in determining if a user has been edited between select and update.' ;

COMMENT ON COLUMN tasker_data.dt_user.username IS 'The username associated with the account.' ;

COMMENT ON COLUMN tasker_data.dt_user.full_name IS 'The name of the account user.' ;

COMMENT ON COLUMN tasker_data.dt_user.email_address IS 'The email address for the account user.' ;

COMMENT ON COLUMN tasker_data.dt_user.email_is_enabled IS 'Indicates if the user wants to be notified (by email) when there is a change to an item that is associated with their account.' ;

COMMENT ON COLUMN tasker_data.dt_user.is_enabled IS 'Indicates if the account is enabled (may log in) or not.' ;

COMMENT ON COLUMN tasker_data.dt_user.is_admin IS 'Indicates if the account has admin privs or not.' ;

COMMENT ON COLUMN tasker_data.dt_user.last_login IS 'The most recent time that the user has logged in.' ;

COMMENT ON COLUMN tasker_data.dt_user.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_user.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_user.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_user.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE tasker_data.dt_user FROM public ;
