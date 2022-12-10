CREATE TABLE tasker_data.st_issue_severity (
    id int2 NOT NULL,
    ranking_id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_issue_severity_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_severity_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_issue_severity OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_issue_severity IS 'Reference table. Indicates how bad/severe an issue is.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.id IS 'Unique ID/value for the severity.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.ranking_id IS 'The priority ranking associated with the severity.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.name IS 'Display name for the severity.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.description IS 'Description of the severity.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_issue_severity.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_issue_severity (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 1, 'Trivial', 'The issue affects neither functionality or data.', true ),
        ( 2, 4, 'Minor', 'The issue affects minor functionality/non-critical data.', false ),
        ( 3, 6, 'Average', 'The issue affects average functionality/data.', false ),
        ( 4, 7, 'Major', 'The issue affects major functionality/data.', false ),
        ( 5, 8, 'Critical', 'The issue affects critical functionality/data.', false ) ;
