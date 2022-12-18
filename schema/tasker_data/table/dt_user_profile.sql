CREATE TABLE tasker_data.dt_user_profile (
    user_id integer NOT NULL,
    edition integer DEFAULT 0 NOT NULL,
    email_is_enabled boolean DEFAULT true NOT NULL,
    full_name text NOT NULL,
    email_address text,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_user_profile_pk PRIMARY KEY ( user_id ) ) ;

ALTER TABLE tasker_data.dt_user_profile OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_user_profile IS 'User profiles for user accounts.' ;

COMMENT ON COLUMN tasker_data.dt_user.user_id IS 'Unique ID for the user account.' ;

COMMENT ON COLUMN tasker_data.dt_user.edition IS 'Indicates the number of edits made to the user record. Intended for use in determining if a user has been edited between select and update.' ;

COMMENT ON COLUMN tasker_data.dt_user.full_name IS 'The name of the account user.' ;

COMMENT ON COLUMN tasker_data.dt_user.email_address IS 'The email address for the account user.' ;

COMMENT ON COLUMN tasker_data.dt_user.email_is_enabled IS 'Indicates if the user wants to be notified (by email) when there is a change to an item that is associated with their account.' ;

COMMENT ON COLUMN tasker_data.dt_user.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_user.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_user.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_user.updated_dt IS 'The timestamp when the row was most recently updated.' ;
