CREATE TABLE tasker_data.dt_user_token (
    updated_dt timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    idle_timeout integer NOT NULL,
    token text NOT NULL,
    CONSTRAINT dt_user_token_pk PRIMARY KEY ( user_id ) ) ;

ALTER TABLE tasker_data.dt_user_token OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_user_token IS 'User authentication/session tokens. The intent being to allow applications to persist tokens over application restarts and/or to enable sharing a token between applications.' ;

COMMENT ON COLUMN tasker_data.dt_user_token.user_id IS 'Unique ID for the user account.' ;

COMMENT ON COLUMN tasker_data.dt_user_token.token IS 'The authentication/session token.' ;

COMMENT ON COLUMN tasker_data.dt_user_token.idle_timeout IS 'The number of minutes that an idle token is valid for (0 for non-expiring tokens).' ;

COMMENT ON COLUMN tasker_data.dt_user_token.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.dt_user_token
    ADD CONSTRAINT dt_user_token_fk01
    FOREIGN KEY ( user_id )
    REFERENCES tasker_data.dt_user ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_user_token FROM public ;
