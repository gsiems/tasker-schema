SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_user_token (
    user_id integer NOT NULL,
    token text NOT NULL,
    idle_timeout integer NOT NULL,
    updated_dt timestamp with time zone NOT NULL,
    CONSTRAINT dt_user_token_pk PRIMARY KEY ( user_id ) ) ;

ALTER TABLE dt_user_token OWNER TO tasker_owner ;

COMMENT ON TABLE dt_user_token IS 'User authentication/session tokens. The intent being to allow applications to persist tokens over application restarts and/or to enable sharing a token between applications.' ;

COMMENT ON column dt_user_token.user_id IS 'Unique ID for the user account.' ;

COMMENT ON column dt_user_token.token IS 'The authentication/session token.' ;

COMMENT ON column dt_user_token.idle_timeout IS 'The number of seconds that an idle token is valid for (< 1 for non-expiring tokens).' ;

COMMENT ON column dt_user_token.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_user_token
    ADD CONSTRAINT dt_user_token_fk01
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

REVOKE ALL ON table dt_user_token FROM public ;
