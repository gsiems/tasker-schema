CREATE TABLE tasker_data.dt_task_user (
    task_id integer NOT NULL,
    user_id integer NOT NULL,
    last_viewed_dt timestamp with time zone,
    created_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_task_user_pk PRIMARY KEY ( task_id, user_id ) ) ;

ALTER TABLE tasker_data.dt_task_user OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task_user IS 'Team members assigned to tasks.' ;

COMMENT ON COLUMN tasker_data.dt_task_user.task_id IS 'The ID of the task' ;

COMMENT ON COLUMN tasker_data.dt_task_user.user_id IS 'The team member assigned to the task.' ;

COMMENT ON COLUMN tasker_data.dt_task_user.permission_id IS 'The ID of the permission for the user.' ;

COMMENT ON COLUMN tasker_data.dt_task_user.last_viewed_dt IS 'The timestamp when the task was last viewed by the user.' ;

COMMENT ON COLUMN tasker_data.dt_task_user.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_user.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE tasker_data.dt_task_user
    ADD CONSTRAINT dt_task_user_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_user
    ADD CONSTRAINT dt_task_user_fk02
    FOREIGN KEY ( user_id )
    REFERENCES tasker_data.dt_user ( id ) ;

ALTER TABLE tasker_data.dt_task_user
    ADD CONSTRAINT dt_task_user_fk03
    FOREIGN KEY ( role_id )
    REFERENCES tasker_data.rt_role ( id ) ;

ALTER TABLE tasker_data.dt_task_user
    ADD CONSTRAINT dt_task_user_fk04
    FOREIGN KEY ( permission_id )
    REFERENCES tasker_data.st_permission ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_user FROM public ;
