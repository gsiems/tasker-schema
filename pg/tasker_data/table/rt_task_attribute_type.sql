CREATE TABLE tasker_data.rt_task_attribute_type (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    created_by_id integer,
    updated_by_id integer,
    eav_attribute_type_id integer NOT NULL,
    task_type_id integer,
    category_id int2 NOT NULL,
    max_allowed int2 DEFAULT 1 NOT NULL,
    display_order int2 DEFAULT 0 NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    CONSTRAINT rt_task_attribute_type_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE tasker_data.rt_task_attribute_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_task_attribute_type IS 'Reference table. Maps EAV attribute types to specific task categories and/or task types.' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.id IS 'Unique ID for an attribute type' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.category_id IS 'The task category to which the attribute type belongs' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.task_type_id IS 'The (optional) task type to which the attribute type belongs. If null then the attribute applies to all tasks in the specified task category' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.eav_attribute_type_id IS 'The attribute type' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.max_allowed IS 'The maximum number of attributes of this type allowed' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.display_order IS 'The order to show the attributes in the UI' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.is_required IS 'Indicates whether or not the attribute is required.' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.is_enabled IS 'Indicates whether or not the attribute is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_attribute_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.rt_task_attribute_type
    ADD CONSTRAINT rt_task_attribute_type_fk01
    FOREIGN KEY ( eav_attribute_type_id )
    REFERENCES tasker_data.rt_eav_attribute_type ( id ) ;

ALTER TABLE tasker_data.rt_task_attribute_type
    ADD CONSTRAINT rt_task_attribute_type_fk02
    FOREIGN KEY ( category_id )
    REFERENCES tasker_data.st_task_category ( id ) ;

ALTER TABLE tasker_data.rt_task_attribute_type
    ADD CONSTRAINT rt_task_attribute_type_fk03
    FOREIGN KEY ( task_type_id )
    REFERENCES tasker_data.rt_task_type ( id ) ;

REVOKE ALL ON TABLE tasker_data.rt_task_attribute_type FROM public ;
