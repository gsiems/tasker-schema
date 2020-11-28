SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_user (
    task_id integer NOT NULL,
    user_id integer NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_task_user_pk PRIMARY KEY ( task_id, user_id ) ) ;

ALTER TABLE dt_task_user OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_user IS 'Team members assigned to tasks.' ;

COMMENT ON COLUMN dt_task_user.task_id IS 'The ID of the task' ;

COMMENT ON COLUMN dt_task_user.user_id IS 'The team member assigned to the task.' ;

COMMENT ON COLUMN dt_task_user.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_user.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE dt_task_user
    ADD CONSTRAINT dt_task_user_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_user
    ADD CONSTRAINT dt_task_user_fk02
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

REVOKE ALL ON TABLE dt_task_user FROM public ;
