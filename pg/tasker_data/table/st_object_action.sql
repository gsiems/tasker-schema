CREATE TABLE tasker_data.st_object_action (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_object_action_pk PRIMARY KEY ( id ),
    CONSTRAINT st_object_action_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_object_action OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_object_action IS 'Reference table. Actions that may be performed on objects.' ;

COMMENT ON COLUMN tasker_data.st_object_action.id IS 'Unique ID for an action.' ;

COMMENT ON COLUMN tasker_data.st_object_action.name IS 'The name for an action.' ;

COMMENT ON COLUMN tasker_data.st_object_action.description IS 'The description of an action.' ;

COMMENT ON COLUMN tasker_data.st_object_action.is_default IS 'Indicates whether or not the action is the default action.' ;

COMMENT ON COLUMN tasker_data.st_object_action.is_enabled IS 'Indicates whether or not the action is available for new use.' ;

INSERT INTO tasker_data.st_object_action (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 'Select', 'Select one or more objects.', true ),
        ( 2, 'Insert', 'Insert one or more objects.', false ),
        ( 3, 'Update', 'Update one or more objects.', false ),
        ( 4, 'Update status', 'Update the status of an object.', false ),
        ( 5, 'Assign', 'Assign an object to someone else.', false ),
        ( 6, 'Delete', 'Delete one or more objects.', false ) ;
