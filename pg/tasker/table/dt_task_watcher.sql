SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_watcher (
    task_id integer NOT NULL,
    user_id integer NOT NULL,
    last_viewed_dt timestamp with time zone,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_task_watcher_pk PRIMARY KEY ( task_id, user_id ) ) ;

ALTER TABLE dt_task_watcher OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_watcher IS 'Users watching for changes to tasks.' ;

COMMENT ON column dt_task_watcher.task_id IS 'The ID of the task' ;

COMMENT ON column dt_task_watcher.user_id IS 'The ID of the user that is watching the task.' ;

COMMENT ON column dt_task_watcher.last_viewed_dt IS 'The timestamp when the task was last viewed by the user.' ;

COMMENT ON column dt_task_watcher.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column dt_task_watcher.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE dt_task_watcher
    ADD CONSTRAINT dt_task_watcher_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_watcher
    ADD CONSTRAINT dt_task_watcher_fk02
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

REVOKE ALL ON table dt_task_watcher FROM public ;
