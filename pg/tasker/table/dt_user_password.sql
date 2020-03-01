SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_user_password (
    user_id integer NOT NULL,
    password_hash text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_user_password_pk PRIMARY KEY ( user_id ) ) ;

ALTER TABLE dt_user_password OWNER TO tasker_owner ;

COMMENT ON TABLE dt_user_password IS 'Passwords user accounts that use database authentication.' ;

COMMENT ON column dt_user_password.user_id IS 'Unique ID for the user account.' ;

COMMENT ON column dt_user_password.password_hash IS 'The hashed value of the password for the account.' ;

COMMENT ON column dt_user_password.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column dt_user_password.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON column dt_user_password.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON column dt_user_password.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_user_password
    ADD CONSTRAINT dt_user_password_fk01
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

REVOKE ALL ON table dt_user_password FROM public ;
