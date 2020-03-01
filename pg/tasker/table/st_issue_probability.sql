set search_path = tasker, pg_catalog ;

CREATE TABLE st_issue_probability (
    id integer NOT NULL,
    priority_id integer NOT NULL,
    name character varying ( 60 ) NOT NULL,
    CONSTRAINT st_issue_probability_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_probability_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_issue_probability OWNER TO tasker_owner ;

COMMENT ON TABLE st_issue_probability IS 'Reference table. Probability/repeatability of triggering the issue.' ;

COMMENT ON column st_issue_probability.id IS 'Unique ID/value for the issue_probability.' ;

COMMENT ON column st_issue_probability.priority_id IS 'The priority associated with the probability.' ;

COMMENT ON column st_issue_probability.name IS 'Display name for the issue_probability.' ;

REVOKE ALL ON table st_issue_probability FROM public ;

ALTER TABLE st_issue_probability
    ADD CONSTRAINT st_issue_probability_fk01
    FOREIGN KEY ( priority_id )
    REFERENCES st_ranking ( id ) ;

INSERT INTO st_issue_probability (id, priority_id, name) VALUES (1, 1, 'Not applicable') ;
INSERT INTO st_issue_probability (id, priority_id, name) VALUES (2, 2, 'Unknown') ;
INSERT INTO st_issue_probability (id, priority_id, name) VALUES (3, 3, 'Random') ;
INSERT INTO st_issue_probability (id, priority_id, name) VALUES (4, 4, 'Rarely') ;
INSERT INTO st_issue_probability (id, priority_id, name) VALUES (5, 5, 'Sometimes') ;
INSERT INTO st_issue_probability (id, priority_id, name) VALUES (6, 8, 'Always') ;
