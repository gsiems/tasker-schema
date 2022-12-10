CREATE TABLE tasker_data.st_permission (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    can_create_task boolean DEFAULT false NOT NULL,
    can_update_task boolean DEFAULT false NOT NULL,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_permission_pk PRIMARY KEY ( id ),
    CONSTRAINT st_permission_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_permission OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_permission IS 'User permissions.' ;

COMMENT ON COLUMN tasker_data.st_permission.id IS 'Unique ID for a permission.' ;

COMMENT ON COLUMN tasker_data.st_permission.name IS 'The name of the permission.' ;

COMMENT ON COLUMN tasker_data.st_permission.description IS 'The description of the permission.' ;

COMMENT ON COLUMN tasker_data.st_permission.can_create_task IS 'Indicates whether or not the permission is allowed to create sub-tasks.' ;

COMMENT ON COLUMN tasker_data.st_permission.can_update_task IS 'Indicates whether or not the permission is allowed to update a task.' ;

COMMENT ON COLUMN tasker_data.st_permission.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_permission.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_permission (
        name,
        can_create_task,
        can_update_task )
    VALUES
        ( 'All', true, true ),
        ( 'Update', false, true ),
        ( 'Create', true, false ),
        ( 'Read', false, false ) ;
