CREATE TABLE tasker_data.st_date_importance (
    id int2 NOT NULL,
    ranking_id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_date_importance_pk PRIMARY KEY ( id ),
    CONSTRAINT st_date_importance_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_date_importance
    ADD CONSTRAINT st_date_importance_fk01
    FOREIGN KEY ( ranking_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

ALTER TABLE tasker_data.st_date_importance OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_date_importance IS 'Reference table. For estimated dates. Indicates how important it is for a date to be met.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.id IS 'Unique ID/value for the severity level.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.ranking_id IS 'The priority ranking associated with the date severity.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.name IS 'Display name for the date severity level.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.description IS 'Description of the date severity level.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_date_importance.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_date_importance (
        id,
        ranking_id,
        name,
        description,
        is_default )
    VALUES
         (1, 1, 'Aspirational', 'Missing the date has no negative implications.', true ),
         (2, 3, 'Minor', 'Missing the date has minor implications.', false ),
         (3, 5, 'Average', 'Missing the date has implications.', false ),
         (4, 7, 'Major', 'Missing the date has major implications.', false ),
         (5, 9, 'Critical', 'Missing the date has critical implications.', false ) ;
