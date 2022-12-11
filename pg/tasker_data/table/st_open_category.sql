CREATE TABLE tasker_data.st_open_category (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_open_category_pk PRIMARY KEY ( id ),
    CONSTRAINT st_open_category_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_open_category OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_open_category IS 'Reference table. Categories for the open statuses.' ;

COMMENT ON COLUMN tasker_data.st_open_category.id IS 'Unique ID for an open category.' ;

COMMENT ON COLUMN tasker_data.st_open_category.name IS 'The name for an open category.' ;

COMMENT ON COLUMN tasker_data.st_open_category.description IS 'The description of an open category.' ;

COMMENT ON COLUMN tasker_data.st_open_category.is_default IS 'Indicates whether or not the category is the default category.' ;

COMMENT ON COLUMN tasker_data.st_open_category.is_enabled IS 'Indicates whether or not the category is available for new use.' ;

INSERT INTO tasker_data.st_open_category (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 'Not Open', 'Statuses that are neither in progress or closed.', true ),
        ( 2, 'Open', 'Statuses that are in progress.', false ),
        ( 3, 'Closed', 'Statuses that are closed.', false ) ;
