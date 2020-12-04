set search_path = tasker, pg_catalog ;

CREATE TABLE st_issue_severity (
    id int2 NOT NULL,
    priority_id int2 NOT NULL,
    name character varying ( 100 ) NOT NULL,
    CONSTRAINT st_issue_severity_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_severity_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_issue_severity OWNER TO tasker_owner ;

COMMENT ON TABLE st_issue_severity IS 'Reference table. Indicates how bad/severe an issue is.' ;

COMMENT ON COLUMN st_issue_severity.id IS 'Unique ID/value for the issue_severity.' ;

COMMENT ON COLUMN st_issue_severity.priority_id IS 'The priority associated with the severity level.' ;

COMMENT ON COLUMN st_issue_severity.name IS 'Display name for the issue_severity.' ;

REVOKE ALL ON TABLE st_issue_severity FROM public ;

ALTER TABLE st_issue_severity
    ADD CONSTRAINT st_issue_severity_fk01
    FOREIGN KEY ( priority_id )
    REFERENCES st_ranking ( id ) ;

INSERT INTO st_issue_severity (id, priority_id, name) VALUES (1, 1, 'Trivial: The issue affects neither functionality or data.') ;
INSERT INTO st_issue_severity (id, priority_id, name) VALUES (2, 4, 'Minor: The issue affects minor functionality/non-critical data.') ;
INSERT INTO st_issue_severity (id, priority_id, name) VALUES (3, 6, 'Average: The issue affects average functionality/data.') ;
INSERT INTO st_issue_severity (id, priority_id, name) VALUES (4, 7, 'Major: The issue affects major functionality/data.') ;
INSERT INTO st_issue_severity (id, priority_id, name) VALUES (5, 8, 'Critical: The issue affects critical functionality/data.') ;
