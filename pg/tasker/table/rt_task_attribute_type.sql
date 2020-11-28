SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_task_attribute_type (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    category_id integer NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    is_enabled boolean DEFAULT true NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT rt_task_attribute_type_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_task_attribute_type_ix1 UNIQUE ( category_id, name ) ) ;

ALTER TABLE rt_task_attribute_type OWNER TO tasker_owner ;

COMMENT ON TABLE rt_task_attribute_type IS 'Reference table. Custom attributes for activities.' ;

COMMENT ON COLUMN rt_task_attribute_type.id IS 'Unique ID for a attribute' ;

COMMENT ON COLUMN rt_task_attribute_type.category_id IS 'The task category to which the attribute belongs' ;

COMMENT ON COLUMN rt_task_attribute_type.name IS 'The name for a attribute.' ;

COMMENT ON COLUMN rt_task_attribute_type.description IS 'The description of the attribute.' ;

COMMENT ON COLUMN rt_task_attribute_type.is_enabled IS 'Indicates whether or not the attribute is available for use.' ;

COMMENT ON COLUMN rt_task_attribute_type.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_attribute_type.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN rt_task_attribute_type.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_attribute_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE rt_task_attribute_type
    ADD CONSTRAINT rt_task_attribute_type_fk01
    FOREIGN KEY ( category_id )
    REFERENCES st_task_category ( id ) ;

REVOKE ALL ON TABLE rt_task_attribute_type FROM public ;
