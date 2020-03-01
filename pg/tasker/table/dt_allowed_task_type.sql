
set search_path = tasker, pg_catalog ;

CREATE TABLE dt_allowed_task_type (
    activity_id integer NOT NULL,
    task_type_id integer NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_allowed_task_type_pk PRIMARY KEY ( activity_id, task_type_id ) ) ;

ALTER TABLE dt_allowed_task_type OWNER TO tasker_owner ;

COMMENT ON TABLE dt_allowed_task_type IS 'Allowed tasks for specific activities (for those activities that restrict the available task types).' ;

COMMENT ON column dt_allowed_task_type.activity_id IS 'The ID of the activity.' ;

COMMENT ON column dt_allowed_task_type.task_type_id IS 'The ID of the type of task.' ;

COMMENT ON column dt_allowed_task_type.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column dt_allowed_task_type.created_dt IS 'The timestamp when the row was created.' ;

CREATE INDEX dt_activity_task_template_idx1 ON dt_allowed_task_type ( activity_id ) ;

CREATE INDEX dt_activity_task_template_idx2 ON dt_allowed_task_type ( task_type_id ) ;

ALTER TABLE dt_allowed_task_type
    ADD CONSTRAINT dt_activity_task_template_fk01
    FOREIGN KEY ( activity_id )
    REFERENCES dt_activity ( id ) ;

ALTER TABLE dt_allowed_task_type
    ADD CONSTRAINT dt_task_fk02
    FOREIGN KEY ( task_type_id )
    REFERENCES rt_task_type ( id ) ;

REVOKE ALL ON table dt_allowed_task_type FROM public ;
