CREATE TABLE tasker_data.st_role (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default
    CONSTRAINT st_role_pk PRIMARY KEY ( id ),
    CONSTRAINT st_role_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_role OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_role IS 'Reference table. Roles that may be assigned to users.' ;

COMMENT ON COLUMN tasker_data.st_role.id IS 'Unique ID for the role.' ;

COMMENT ON COLUMN tasker_data.st_role.name IS 'The name for the role.' ;

COMMENT ON COLUMN tasker_data.st_role.description IS 'The description of the role.' ;

COMMENT ON COLUMN tasker_data.st_role.is_activity_role IS 'Indicates whether or not the role is for activities.' ;

COMMENT ON COLUMN tasker_data.st_role.is_default IS 'Indicates whether or not the role is the default role.' ;

COMMENT ON COLUMN tasker_data.st_role.is_enabled IS 'Indicates whether or not the role is available for new use.' ;

INSERT INTO tasker_data.st_role (
        id,
        name,
        description,
        is_default )
    VALUES
        ( 10, 'Observer',       'Activity role for observers', true ),
        ( 20, 'Reporter',       'Activity role for reporters', false ),
        ( 30, 'Member',         'Activity role for working on activities', false ),
        ( 40, 'Analyst',        'Activity role for (business) analysts', false ),
        ( 50, 'Manager',        'Activity role for managing activities', false ),
        ( 60, 'Activity Owner', 'Activity role for administering activities', false ) ;
