CREATE TABLE tasker_data.rt_eav_attribute_type (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    datatype_id integer NOT NULL,
    created_by integer,
    updated_by integer,
    -- TODO: array of valid values?
    is_enabled boolean DEFAULT true NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT rt_eav_attribute_type_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_eav_attribute_type_ix1 UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.rt_eav_attribute_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_eav_attribute_type IS 'Reference table. Types of EAV attributes.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.id IS 'Unique ID/value for the data type.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.datatype_id IS 'The datatype of the attribute type.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.name IS 'The name for the attribute type.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.description IS 'The description of the attribute type.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_eav_attribute_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.rt_eav_attribute_type
    ADD CONSTRAINT rt_eav_attribute_type_fk01
    FOREIGN KEY ( datatype_id )
    REFERENCES tasker_data.st_eav_attribute_datatype ( id ) ;

REVOKE ALL ON TABLE tasker_data.rt_eav_attribute_type FROM public ;
