CREATE TABLE tasker_data.st_issue_workaround (
    id int2 NOT NULL,
    priority_id int2 NOT NULL,
    name text NOT NULL,
    CONSTRAINT st_issue_workaround_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_workaround_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_issue_workaround OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_issue_workaround IS 'Reference table. The type of workarounds available for an issue.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.id IS 'Unique ID/value for the issue_workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.priority_id IS 'The priority associated with the workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.name IS 'Display name for the issue_workaround.' ;

REVOKE ALL ON TABLE tasker_data.st_issue_workaround FROM public ;

ALTER TABLE tasker_data.st_issue_workaround
    ADD CONSTRAINT st_issue_workaround_fk01
    FOREIGN KEY ( priority_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

INSERT INTO tasker_data.st_issue_workaround (id, priority_id, name) VALUES (1, 1, 'Not applicable/not required') ;
INSERT INTO tasker_data.st_issue_workaround (id, priority_id, name) VALUES (2, 2, 'An easy/obvious workaround exists') ;
INSERT INTO tasker_data.st_issue_workaround (id, priority_id, name) VALUES (3, 4, 'A reasonable/not difficult workaround exists') ;
INSERT INTO tasker_data.st_issue_workaround (id, priority_id, name) VALUES (4, 6, 'A difficult/non-obvious workaround exists') ;
INSERT INTO tasker_data.st_issue_workaround (id, priority_id, name) VALUES (5, 8, 'There is no known workaround') ;
