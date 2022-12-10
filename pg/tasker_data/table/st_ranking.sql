CREATE TABLE tasker_data.st_ranking (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_ranking_pk PRIMARY KEY ( id ),
    CONSTRAINT st_ranking_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_ranking OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_ranking IS 'Reference table. Ranking values for attributes such as priority, urgency, reversibility, etc.' ;

COMMENT ON COLUMN tasker_data.st_ranking.id IS 'Unique ID/value for the ranking.' ;

COMMENT ON COLUMN tasker_data.st_ranking.name IS 'Display name for the ranking.' ;

COMMENT ON COLUMN tasker_data.st_ranking.is_default IS 'Indicates whether or not the row is the default row.' ;

INSERT INTO tasker_data.st_ranking (
        id,
        name,
        is_default )
    VALUES
        ( 1, 'None/Not', true ),
        ( 2, 'Very Low', false ),
        ( 3, 'Low', false ),
        ( 4, 'Medium Low', false ),
        ( 5, 'Medium', false ),
        ( 6, 'Medium High', false ),
        ( 7, 'High', false ),
        ( 8, 'Very High', false ),
        ( 9, 'Extreme', false ) ;
