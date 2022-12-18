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
        name,
        description )
    VALUES
        ( 1, 'activity', 'Activity tasks' ),
        ( 2, 'issue', 'Issue tasks' ),
        ( 3, 'meeting', 'Meeting tasks' ),
        ( 4, 'pip', 'PIP tasks' ),
        ( 5, 'requirement', 'Requirement tasks' ),
        ( 6, 'task', 'Regular, nothing special, tasks' ),
        ( 7, 'comment', 'Comments on tasks' ),
        ( 8, 'journal', 'Journal entries for tasks' ),
        ( 9, 'reference', 'Reference data' ),
        ( 10, 'user', 'Users' ),
        ( 11, 'profile', 'User profiles' ) ;
