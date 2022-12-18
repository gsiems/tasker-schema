CREATE TABLE tasker_data.dt_task_association (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    task_id integer NOT NULL,
    associated_task_id integer NOT NULL,
    created_by_id integer,
    association_type_id int2 NOT NULL,
    CONSTRAINT dt_task_association_pk PRIMARY KEY ( task_id, associated_task_id ),
    CONSTRAINT dt_task_association_ck1 CHECK ( ( task_id <> associated_task_id ) ) ) ;

ALTER TABLE tasker_data.dt_task_association OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task_association IS 'Tasks that have an association with other tasks.' ;

COMMENT ON COLUMN tasker_data.dt_task_association.task_id IS 'The ID of the task' ;

COMMENT ON COLUMN tasker_data.dt_task_association.associated_task_id IS 'The ID of the associated task.' ;

COMMENT ON COLUMN tasker_data.dt_task_association.association_type_id IS 'The ID of the association type.' ;

COMMENT ON COLUMN tasker_data.dt_task_association.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_association.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE tasker_data.dt_task_association
    ADD CONSTRAINT dt_task_association_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_association
    ADD CONSTRAINT dt_task_association_fk02
    FOREIGN KEY ( associated_task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_association
    ADD CONSTRAINT dt_task_association_fk03
    FOREIGN KEY ( association_type_id )
    REFERENCES tasker_data.st_association_type ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_association FROM public ;
