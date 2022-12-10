CREATE TABLE tasker_data.st_issue_probability (
    id int2 NOT NULL,
    ranking_id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_issue_probability_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_probability_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_issue_probability
    ADD CONSTRAINT st_issue_probability_fk01
    FOREIGN KEY ( ranking_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

ALTER TABLE tasker_data.st_issue_probability OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_issue_probability IS 'Reference table. Probability/repeatability of triggering the issue.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.id IS 'Unique ID/value for the probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.ranking_id IS 'The priority ranking associated with the probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.name IS 'Display name for the probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.description IS 'Description of the probability.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_issue_probability.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_issue_probability (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 1, 'Not applicable', '', true ),
        ( 2, 2, 'Unknown', '', false ),
        ( 4, 4, 'Rarely', '', false ),
        ( 5, 6, 'Sometimes', '', false ),
        ( 6, 8, 'Often', '', false ),
        ( 7, 9, 'Always', '', false ) ;
