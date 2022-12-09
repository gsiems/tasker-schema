CREATE TABLE tasker_data.st_issue_probability (
    id int2 NOT NULL,
    priority_id int2 NOT NULL,
    name character varying ( 60 ) NOT NULL,
    CONSTRAINT st_issue_probability_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_probability_ix1 UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_issue_probability OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_issue_probability IS 'Reference table. Probability/repeatability of triggering the issue.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.id IS 'Unique ID/value for the issue_probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.priority_id IS 'The priority associated with the probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.name IS 'Display name for the issue_probability.' ;

REVOKE ALL ON TABLE tasker_data.st_issue_probability FROM public ;

ALTER TABLE tasker_data.st_issue_probability
    ADD CONSTRAINT st_issue_probability_fk01
    FOREIGN KEY ( priority_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (1, 1, 'Not applicable') ;
INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (2, 2, 'Unknown') ;
INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (3, 3, 'Random') ;
INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (4, 4, 'Rarely') ;
INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (5, 5, 'Sometimes') ;
INSERT INTO tasker_data.st_issue_probability (id, priority_id, name) VALUES (6, 8, 'Always') ;
