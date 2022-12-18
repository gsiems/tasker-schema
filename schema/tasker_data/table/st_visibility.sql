CREATE TABLE tasker_data.st_visibility (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_visibility_pk PRIMARY KEY ( id ),
    CONSTRAINT st_visibility_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_visibility OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_visibility IS 'System reference table. Visibility levels for activities.' ;

COMMENT ON COLUMN tasker_data.st_visibility.id IS 'Unique ID for a visibility level.' ;

COMMENT ON COLUMN tasker_data.st_visibility.name IS 'The name for the visibility level.' ;

COMMENT ON COLUMN tasker_data.st_visibility.description IS 'The description of the visibility level.' ;

COMMENT ON COLUMN tasker_data.st_visibility.is_default IS 'Indicates whether or not the visibility level is the default visibility level.' ;

COMMENT ON COLUMN tasker_data.st_visibility.is_enabled IS 'Indicates whether or not the visibility level is available for new use.' ;

INSERT INTO tasker_data.st_visibility (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 'Public', 'The activity is visible to anyone that can access the application.', false ),
        ( 2, 'Protected', 'The activity is only visible to users that are logged in.', false ),
        ( 3, 'Private', 'The activity is only visible to activity members.', true ) ;
