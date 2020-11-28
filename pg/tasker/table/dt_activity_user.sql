SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_activity_user (
    activity_id integer NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_activity_user_pk PRIMARY KEY ( activity_id, user_id ) ) ;

ALTER TABLE dt_activity_user OWNER TO tasker_owner ;

COMMENT ON TABLE dt_activity_user IS 'Users (team menbers) assigned to an activity.' ;

COMMENT ON COLUMN dt_activity_user.activity_id IS 'The ID of the activity.' ;

COMMENT ON COLUMN dt_activity_user.user_id IS 'The ID of the assigned user.' ;

COMMENT ON COLUMN dt_activity_user.role_id IS 'The ID of the role that the user fulfills on the activity team.' ;

COMMENT ON COLUMN dt_activity.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity.updated_dt IS 'The timestamp when the row was most recently updated.' ;

COMMENT ON COLUMN dt_activity_user.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity_user.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE dt_activity_user
    ADD CONSTRAINT dt_activity_user_fk01
    FOREIGN KEY ( activity_id )
    REFERENCES dt_activity ( id ) ;

ALTER TABLE dt_activity_user
    ADD CONSTRAINT dt_activity_user_fk02
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

ALTER TABLE dt_activity_user
    ADD CONSTRAINT dt_activity_user_fk03
    FOREIGN KEY ( role_id )
    REFERENCES st_role ( id ) ;

REVOKE ALL ON TABLE dt_activity_user FROM public ;
