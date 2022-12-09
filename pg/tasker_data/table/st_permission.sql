CREATE TABLE tasker_data.st_permission (
    id int2 NOT NULL,
    can_create_task boolean DEFAULT false NOT NULL,
    can_update_task boolean DEFAULT false NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT st_permission_pk PRIMARY KEY ( id ),
    CONSTRAINT st_permission_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_permission OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_permission IS 'User permissions.' ;

COMMENT ON COLUMN tasker_data.st_permission.id IS 'Unique ID for a permission.' ;

COMMENT ON COLUMN tasker_data.st_permission.can_create_task IS 'Indicates whether or not the permission is allowed to create sub-tasks.' ;

COMMENT ON COLUMN tasker_data.st_permission.can_update_task IS 'Indicates whether or not the permission is allowed to update a task.' ;

COMMENT ON COLUMN tasker_data.st_permission.name IS 'The name of the permission.' ;

COMMENT ON COLUMN tasker_data.st_permission.description IS 'The description of the permission.' ;

REVOKE ALL ON TABLE tasker_data.st_permission FROM public ;

INSERT INTO tasker_data.st_permission (id, name, can_create_task, can_update_task) VALUES (2, 'All', true, true) ;
INSERT INTO tasker_data.st_permission (id, name, can_create_task, can_update_task) VALUES (3, 'Update', false, true) ;
INSERT INTO tasker_data.st_permission (id, name, can_create_task, can_update_task) VALUES (4, 'Create', true, false) ;
INSERT INTO tasker_data.st_permission (id, name, can_create_task, can_update_task) VALUES (5, 'Read', false, false) ;
