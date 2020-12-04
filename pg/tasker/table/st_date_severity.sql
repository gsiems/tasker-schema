set search_path = tasker, pg_catalog ;

CREATE TABLE st_date_severity (
    id int2 NOT NULL,
    name character varying ( 60 ) NOT NULL,
    CONSTRAINT st_date_severity_pk PRIMARY KEY ( id ),
    CONSTRAINT st_date_severity_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_date_severity OWNER TO tasker_owner ;

COMMENT ON TABLE st_date_severity IS 'Reference table. For estimated dates. Indicates how important it is for a date to be met.' ;

COMMENT ON COLUMN st_date_severity.id IS 'Unique ID/value for the severity level.' ;

COMMENT ON COLUMN st_date_severity.name IS 'Display name for the severity level.' ;

REVOKE ALL ON TABLE st_date_severity FROM public ;

INSERT INTO st_date_severity (id, name) VALUES (1, 'Aspirational: Missing the date has no implications.') ;
INSERT INTO st_date_severity (id, name) VALUES (4, 'Minor: Missing the date has minor implications.') ;
INSERT INTO st_date_severity (id, name) VALUES (6, 'Average: Missing the date has implications.') ;
INSERT INTO st_date_severity (id, name) VALUES (7, 'Major: Missing the date has major implications.') ;
INSERT INTO st_date_severity (id, name) VALUES (8, 'Critical: Missing the date has critical implications.') ;
