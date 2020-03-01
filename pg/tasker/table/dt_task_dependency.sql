SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_dependency (
    task_id integer NOT NULL,
    dependent_task_id integer NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_task_dependency_pk PRIMARY KEY ( task_id, dependent_task_id ),
    CONSTRAINT dt_task_dependency_ck1 CHECK ( ( task_id <> dependent_task_id ) ) ) ;

ALTER TABLE dt_task_dependency OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_dependency IS 'Tasks that depend on other tasks.' ;

COMMENT ON column dt_task_dependency.task_id IS 'The ID of the task' ;

COMMENT ON column dt_task_dependency.dependent_task_id IS 'The ID of the dependent task.' ;

COMMENT ON column dt_task_dependency.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column dt_task_dependency.created_dt IS 'The timestamp when the row was created.' ;

ALTER TABLE dt_task_dependency
    ADD CONSTRAINT dt_task_dependency_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_dependency
    ADD CONSTRAINT dt_task_dependency_fk02
    FOREIGN KEY ( dependent_task_id )
    REFERENCES dt_task ( id ) ;

REVOKE ALL ON table dt_task_dependency FROM public ;
