CREATE TABLE tasker_data.st_issue_workaround (
    id int2 NOT NULL,
    ranking_id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_issue_workaround_pk PRIMARY KEY ( id ),
    CONSTRAINT st_issue_workaround_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_issue_workaround
    ADD CONSTRAINT st_issue_workaround_fk01
    FOREIGN KEY ( ranking_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

ALTER TABLE tasker_data.st_issue_workaround OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_issue_workaround IS 'Reference table. The type of workarounds available for an issue.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.id IS 'Unique ID/value for the workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.ranking_id IS 'The priority ranking associated with the workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.name IS 'Display name for the workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.description IS 'Description of the workaround.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_issue_workaround.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_issue_workaround (
        id,
        ranking_id,
        name,
        description,
        is_default )
    VALUES
        ( 1, 1, 'Not applicable', 'No workaround is required', true ),
        ( 2, 2, 'Easy', 'AN easy/obvious workaround exists', false ),
        ( 3, 4, 'Reasonable', 'A reasonable/not difficult workaround exists', false ),
        ( 4, 6, 'Difficult', 'A difficult/non-obvious workaround exists', false ),
        ( 5, 8, 'None', 'There is no known workaround', false ) ;
