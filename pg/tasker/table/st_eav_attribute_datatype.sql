set search_path = tasker, pg_catalog ;

CREATE TABLE st_eav_attribute_datatype (
    id int2 NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT st_eav_attribute_datatype_pk PRIMARY KEY ( id ),
    CONSTRAINT st_eav_attribute_datatype_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_eav_attribute_datatype OWNER TO tasker_owner ;

COMMENT ON TABLE st_eav_attribute_datatype IS 'Reference table. Supported data types for EAV attributes.' ;

COMMENT ON COLUMN st_eav_attribute_datatype.id IS 'Unique ID/value for the data type.' ;

COMMENT ON COLUMN st_eav_attribute_datatype.name IS 'The name of the datatype.' ;

COMMENT ON COLUMN st_eav_attribute_datatype.description IS 'The description of the datatype.' ;

REVOKE ALL ON TABLE st_eav_attribute_datatype FROM public ;
