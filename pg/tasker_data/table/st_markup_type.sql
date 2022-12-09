/* TODO

Do we want, somewhere, to support/enable/disable markup options, either
globally or per task for such things as syntax highlighting, LaTeX
equation rendering, diagramming, etc.?

*/

CREATE TABLE tasker_data.st_markup_type (
    id int2 NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT st_markup_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_markup_type_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_markup_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_markup_type IS 'Reference table. Types of markup schemes that are supported.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.id IS 'Unique ID for a markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.name IS 'Display name for the markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.description IS 'Optional description for a markup type.' ;

COMMENT ON COLUMN tasker_data.st_markup_type.is_enabled IS 'Indicates whether or not the markup type is available for use.' ;

REVOKE ALL ON TABLE tasker_data.st_markup_type FROM public ;

INSERT INTO tasker_data.st_markup_type (id, name, description, is_enabled) VALUES (1, 'Plaintext', NULL, true) ;
INSERT INTO tasker_data.st_markup_type (id, name, description, is_enabled) VALUES (2, 'Markdown', NULL, true) ;
--INSERT INTO tasker_data.st_markup_type (id, name, description, is_enabled) VALUES (3, 'Creole', NULL, true) ;
