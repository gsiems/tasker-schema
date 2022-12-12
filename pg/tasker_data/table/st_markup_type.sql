/* TODO

Do we want, somewhere, to support/enable/disable markup options, either
globally or per task for such things as syntax highlighting, LaTeX
equation rendering, diagramming, etc.?

*/

CREATE TABLE tasker_data.st_markup_type (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_markup_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_markup_type_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_markup_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_markup_type IS 'Reference table. Types of markup schemes that are supported.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.id IS 'Unique ID for a markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.name IS 'Display name for the markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.description IS 'Optional description for a markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_markup_type (
        id,
        name )
    VALUES
        ( 1, 'Plaintext' ),
        ( 2, 'Markdown' ) ;
