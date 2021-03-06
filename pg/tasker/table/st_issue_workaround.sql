set search_path = tasker, pg_catalog ;

CREATE TABLE st_issue_workaround (
    id int2 NOT NULL,
    priority_id int2 NOT NULL,
    name character varying ( 100 ) NOT NULL,
    CONSTRAINT st_issue_workaround_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_workaround_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_issue_workaround OWNER TO tasker_owner ;

COMMENT ON TABLE st_issue_workaround IS 'Reference table. The type of workarounds available for an issue.' ;

COMMENT ON COLUMN st_issue_workaround.id IS 'Unique ID/value for the issue_workaround.' ;

COMMENT ON COLUMN st_issue_workaround.priority_id IS 'The priority associated with the workaround.' ;

COMMENT ON COLUMN st_issue_workaround.name IS 'Display name for the issue_workaround.' ;

REVOKE ALL ON TABLE st_issue_workaround FROM public ;

ALTER TABLE st_issue_workaround
    ADD CONSTRAINT st_issue_workaround_fk01
    FOREIGN KEY ( priority_id )
    REFERENCES st_ranking ( id ) ;

INSERT INTO st_issue_workaround (id, priority_id, name) VALUES (1, 1, 'Not applicable/not required') ;
INSERT INTO st_issue_workaround (id, priority_id, name) VALUES (2, 2, 'An easy/obvious workaround exists') ;
INSERT INTO st_issue_workaround (id, priority_id, name) VALUES (3, 4, 'A reasonable/not difficult workaround exists') ;
INSERT INTO st_issue_workaround (id, priority_id, name) VALUES (4, 6, 'A difficult/non-obvious workaround exists') ;
INSERT INTO st_issue_workaround (id, priority_id, name) VALUES (5, 8, 'There is no known workaround') ;
