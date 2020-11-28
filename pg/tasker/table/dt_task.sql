
set search_path = tasker, pg_catalog ;

CREATE TABLE dt_task (
    id serial NOT NULL,
    parent_id integer,
    activity_id integer NOT NULL,
    task_type_id integer NOT NULL,
    status_id integer,
    priority_id integer,
    markup_type_id integer,
    task_name character varying ( 200 ) NOT NULL,
    actual_start date,
    actual_end date,
    time_estimate interval,
    description_markup text,
    description_html text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_task_ck1 CHECK ( ( id <> parent_id ) ),
    CONSTRAINT dt_task_ix1 UNIQUE ( id, activity_id ) ) ;

ALTER TABLE dt_task OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task IS 'Tasks.' ;

COMMENT ON COLUMN dt_task.id IS 'The unique ID for the task.' ;

COMMENT ON COLUMN dt_task.parent_id IS 'The ID of the parent task (if any).' ;

COMMENT ON COLUMN dt_task.task_type_id IS 'Indicates the type of task.' ;

COMMENT ON COLUMN dt_task.status_id IS 'The status of the task.' ;

COMMENT ON COLUMN dt_task.priority_id IS 'The priority of the task.' ;

COMMENT ON COLUMN dt_task.markup_type_id IS 'The ID of the markup format used for the description_markup column.' ;

COMMENT ON COLUMN dt_task.task_name IS 'The name for the task.' ;

COMMENT ON COLUMN dt_task.actual_start IS 'The actual date that work on the task was started.' ;

COMMENT ON COLUMN dt_task.actual_end IS 'The actual date that the task was finished.' ;

COMMENT ON COLUMN dt_task.time_estimate IS 'The estimated time that it should take to implement the task.' ;

COMMENT ON COLUMN dt_task.description_markup IS 'A description of the task and/or the purpose of the task.' ;

COMMENT ON COLUMN dt_task.description_html IS 'The description in HTML format.' ;

COMMENT ON COLUMN dt_task.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task.updated_dt IS 'The timestamp when the row was most recently updated.' ;

CREATE INDEX dt_task_idx1 ON dt_task ( parent_id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk01
    FOREIGN KEY ( parent_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk02
    FOREIGN KEY ( parent_id, activity_id )
    REFERENCES dt_task ( id, activity_id )
    ON UPDATE CASCADE ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk03
    FOREIGN KEY ( activity_id )
    REFERENCES dt_activity ( id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk04
    FOREIGN KEY ( task_type_id )
    REFERENCES rt_task_type ( id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk05
    FOREIGN KEY ( status_id )
    REFERENCES rt_task_status ( id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk06
    FOREIGN KEY ( priority_id )
    REFERENCES st_ranking ( id ) ;

ALTER TABLE dt_task
    ADD CONSTRAINT dt_task_fk07
    FOREIGN KEY ( markup_type_id )
    REFERENCES st_markup_type ( id ) ;

REVOKE ALL ON TABLE dt_task FROM public ;
