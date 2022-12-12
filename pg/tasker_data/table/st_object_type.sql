CREATE TABLE tasker_data.st_object_type (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_object_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_object_type_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_object_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_object_type IS 'Reference table. Objects (tasks, comments, journals) that can have assigned permissions.' ;

COMMENT ON COLUMN tasker_data.st_object_type.id IS 'Unique ID for the object.' ;

COMMENT ON COLUMN tasker_data.st_object_type.name IS 'The name of the object.' ;

COMMENT ON COLUMN tasker_data.st_object_type.description IS 'The description of the object.' ;

COMMENT ON COLUMN tasker_data.st_object_type.is_enabled IS 'Indicates whether or not the object is available for use.' ;

INSERT INTO tasker_data.st_object_type (
        id,
        name )
    VALUES
        ( 1, 'activity' ),
        ( 2, 'issue' ),
        ( 3, 'meeting' ),
        ( 4, 'pip' ),
        ( 5, 'requirement' ),
        ( 6, 'task' ),
        ( 7, 'comment' ),
        ( 8, 'journal' ),
        ( 9, 'ref_data' ),
        ( 10, 'user' ) ;
