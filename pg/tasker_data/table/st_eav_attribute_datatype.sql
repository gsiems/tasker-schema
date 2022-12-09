CREATE TABLE tasker_data.st_eav_attribute_datatype (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT st_eav_attribute_datatype_pk PRIMARY KEY ( id ),
    CONSTRAINT st_eav_attribute_datatype_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_eav_attribute_datatype OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_eav_attribute_datatype IS 'Reference table. Supported data types for EAV attributes.' ;

COMMENT ON COLUMN tasker_data.st_eav_attribute_datatype.id IS 'Unique ID/value for the data type.' ;

COMMENT ON COLUMN tasker_data.st_eav_attribute_datatype.name IS 'The name of the datatype.' ;

COMMENT ON COLUMN tasker_data.st_eav_attribute_datatype.description IS 'The description of the datatype.' ;

REVOKE ALL ON TABLE tasker_data.st_eav_attribute_datatype FROM public ;
