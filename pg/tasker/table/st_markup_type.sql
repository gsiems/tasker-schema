/* TODO

Do we want, somewhere, to support/enable/disable markup options, either
globally or per task for such things as syntax highlighting, LaTeX
equation rendering, diagramming, etc.?

*/
set search_path = tasker, pg_catalog ;

CREATE TABLE st_markup_type (
    id integer NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    is_enabled boolean DEFAULT true NOT NULL,
    CONSTRAINT st_markup_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_markup_type_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_markup_type OWNER TO tasker_owner ;

COMMENT ON TABLE st_markup_type IS 'Reference table. Types of markup schemes that are supported.' ;

COMMENT ON COLUMN st_markup_type.id IS 'Unique ID for a markup type.' ;

COMMENT ON COLUMN st_markup_type.name IS 'Display name for the markup type.' ;

COMMENT ON COLUMN st_markup_type.description IS 'Optional description for a markup type.' ;

COMMENT ON COLUMN st_markup_type.is_enabled IS 'Indicates whether or not the markup type is available for use.' ;

REVOKE ALL ON TABLE st_markup_type FROM public ;

INSERT INTO st_markup_type (id, name, description, is_enabled) VALUES (1, 'Plaintext', NULL, true) ;
INSERT INTO st_markup_type (id, name, description, is_enabled) VALUES (2, 'Markdown', NULL, true) ;
--INSERT INTO st_markup_type (id, name, description, is_enabled) VALUES (3, 'Creole', NULL, true) ;
