SET search_path = tasker, pg_catalog ;

CREATE TABLE st_visibility (
    id int2 NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT st_visibility_pk PRIMARY KEY ( id ),
    CONSTRAINT st_visibility_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_visibility OWNER TO tasker_owner ;

COMMENT ON TABLE st_visibility IS 'System reference table. Visibility levels for activities.' ;

COMMENT ON COLUMN st_visibility.id IS 'Unique ID for a visibility level.' ;

COMMENT ON COLUMN st_visibility.name IS 'The name for the visibility level.' ;

COMMENT ON COLUMN st_visibility.description IS 'The description of the visibility level.' ;

REVOKE ALL ON TABLE st_visibility FROM public ;

INSERT INTO st_visibility (id, name, description) VALUES (1, 'Public', 'The task is visible to anyone that can access the application.') ;
INSERT INTO st_visibility (id, name, description) VALUES (2, 'Protected', 'The task is only visible to users that are logged in.') ;
INSERT INTO st_visibility (id, name, description) VALUES (3, 'Private', 'The task is only visible to task team members.') ;
