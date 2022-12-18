CREATE TABLE tasker_data.st_object_permission (
    object_type_id int2 NOT NULL,
    action_id int2 NOT NULL,
    minimum_role_id int2 NOT NULL,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_object_permission_pk PRIMARY KEY ( object_type_id, action_id, minimum_role_id ) ) ;

ALTER TABLE tasker_data.st_object_permission
    ADD CONSTRAINT st_object_permission_fk01
    FOREIGN KEY ( object_type_id )
    REFERENCES tasker_data.st_object_type ( id ) ;

ALTER TABLE tasker_data.st_object_permission
    ADD CONSTRAINT st_object_permission_fk02
    FOREIGN KEY ( action_id )
    REFERENCES tasker_data.st_object_action ( id ) ;

ALTER TABLE tasker_data.st_object_permission
    ADD CONSTRAINT st_object_permission_fk03
    FOREIGN KEY ( minimum_role_id )
    REFERENCES tasker_data.st_role ( id ) ;

ALTER TABLE tasker_data.st_object_permission OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_object_permission IS 'Reference table. Permitted actions for objects.' ;

COMMENT ON COLUMN tasker_data.st_object_permission.object_type_id IS 'The object type that the permission is for.' ;

COMMENT ON COLUMN tasker_data.st_object_permission.action_id IS 'The action to permit.' ;

COMMENT ON COLUMN tasker_data.st_object_permission.minimum_role_id IS 'The minimum role required to perform the action.' ;

COMMENT ON COLUMN tasker_data.st_object_permission.is_enabled IS 'Indicates whether or not the role permission is enabled.' ;

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 10, 1, 1 ), -- Observer, Select, Activity
        ( 10, 1, 2 ), -- Observer, Select, Issue
        ( 10, 1, 3 ), -- Observer, Select, Meeting
        ( 10, 1, 4 ), -- Observer, Select, PIP
        ( 10, 1, 5 ), -- Observer, Select, Requirement
        ( 10, 1, 6 ), -- Observer, Select, Task
        ( 10, 1, 7 ), -- Observer, Select, Comment
        ( 10, 1, 8 ) ; -- Observer, Select, Journal

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 20, 2, 2 ), -- Reporter, Insert, Issue
        ( 20, 3, 2 ) ; -- Reporter, Update, Issue

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 30, 2, 3 ), -- Member, Insert, Meeting
        ( 30, 2, 6 ), -- Member, Insert, Task
        ( 30, 2, 7 ), -- Member, Insert, Comment
        ( 30, 2, 8 ) ; -- Member, Insert, Journal

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 40, 2, 5 ) ; -- Member, Insert, Requirement

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 50, 2, 4 ), -- Manager, Insert, PIP
        ( 50, 3, 4 ), -- Manager, Update, PIP
        ( 50, 4, 2 ), -- Manager, Update status, Issue
        ( 50, 4, 5 ), -- Manager, Update status, Requirement
        ( 50, 4, 6 ), -- Manager, Update status, Task
        ( 50, 5, 2 ), -- Manager, Assign, Issue
        ( 50, 5, 6 ), -- Manager, Assign, Task
        ( 50, 5, 5 ) ; -- Manager, Assign, Requirement

INSERT INTO tasker_data.st_object_permission (
        minimum_role_id,
        action_id,
        object_type_id )
    VALUES
        ( 60, 2, 1 ), -- Administrator, Insert, (sub)Activity
        ( 60, 2, 4 ), -- Administrator, Insert, PIP
        ( 60, 3, 1 ), -- Administrator, Update, Activity
        ( 60, 3, 2 ), -- Administrator, Update, Issue
        ( 60, 3, 4 ), -- Administrator, Update, PIP
        ( 60, 6, 1 ), -- Administrator, Delete, (sub)Activity
        ( 60, 6, 3 ), -- Administrator, Delete, Meeting
        ( 60, 6, 4 ), -- Administrator, Delete, PIP
        ( 60, 6, 5 ), -- Administrator, Delete, Requirement
        ( 60, 6, 6 ), -- Administrator, Delete, Task
        ( 60, 6, 7 ) ; -- Administrator, Delete, Comment
