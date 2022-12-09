CREATE TABLE tasker_data.dt_task_attribute (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    task_id integer NOT NULL,
    attribute_type_id integer NOT NULL,
    created_by integer,
    updated_by integer,
    attribute_text text,
    -- TODO: do we want attribute columns for other data types?
    CONSTRAINT dt_task_attribute_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE tasker_data.dt_task_attribute OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task_attribute IS 'Custom attributes for tasks.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.id IS 'The unique ID for an attribute entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.attribute_type_id IS 'The ID of attribute type.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.attribute_text IS 'The text of the attribute.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_attribute.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.dt_task_attribute
    ADD CONSTRAINT dt_task_attribute_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_attribute
    ADD CONSTRAINT dt_task_attribute_fk02
    FOREIGN KEY ( attribute_type_id )
    REFERENCES tasker_data.rt_task_attribute_type ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_attribute FROM public ;
