CREATE TABLE tasker_data.st_association_type (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean default false,
    is_enabled boolean default true,
    CONSTRAINT st_association_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_association_type_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_association_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_association_type IS 'Reference table. Types of associations between tasks.' ;

COMMENT ON COLUMN tasker_data.st_association_type.id IS 'Unique ID for a type of task association.' ;

COMMENT ON COLUMN tasker_data.st_association_type.name IS 'The name for a type of task association.' ;

COMMENT ON COLUMN tasker_data.st_association_type.description IS 'The description of a task association.' ;

COMMENT ON COLUMN tasker_data.st_association_type.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_association_type.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_association_type (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 'Association', 'Task has an association with another task.', true ),
        ( 2, 'Dependency', 'Task has a dependency on another task.', false ),
        ( 3, 'Duplicate', 'Task is a duplicate of another task.', false ) ;
