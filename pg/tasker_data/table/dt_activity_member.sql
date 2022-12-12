CREATE TABLE tasker_data.dt_activity_member (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    activity_id integer NOT NULL,
    user_id integer NOT NULL,
    role_id int2 NOT NULL,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_activity_member_pk PRIMARY KEY (id ),
    CONSTRAINT dt_activity_member_nk UNIQUE ( activity_id, user_id ) ) ;

ALTER TABLE tasker_data.dt_activity_member
    ADD CONSTRAINT dt_activity_member_fk01
    FOREIGN KEY ( activity_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_activity_member
    ADD CONSTRAINT dt_activity_member_fk02
    FOREIGN KEY ( user_id )
    REFERENCES tasker_data.dt_user ( id ) ;

ALTER TABLE tasker_data.dt_activity_member
    ADD CONSTRAINT dt_activity_member_fk03
    FOREIGN KEY ( role_id )
    REFERENCES tasker_data.st_role ( id ) ;

ALTER TABLE tasker_data.dt_activity_member OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_activity_member IS 'Team members assigned to tasks.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.id IS 'The unique ID for the activity-member.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.activity_id IS 'The activity that the user is a member of.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.user_id IS 'The user that is a member of the activity.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.role_id IS 'The role that the user has for the activity.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_activity_member.updated_dt IS 'The timestamp when the row was most recently updated.' ;
