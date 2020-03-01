SET search_path = tasker, pg_catalog ;

CREATE TABLE st_role (
    id integer NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    is_activity_owner boolean DEFAULT false NOT NULL,
    can_create_task boolean DEFAULT false NOT NULL,
    can_update_task boolean DEFAULT false NOT NULL,
    CONSTRAINT st_role_pk PRIMARY KEY ( id ),
    CONSTRAINT st_role_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_role OWNER TO tasker_owner ;

COMMENT ON TABLE st_role IS 'User roles.' ;

COMMENT ON column st_role.id IS 'Unique ID for a role.' ;

COMMENT ON column st_role.name IS 'The name of the role.' ;

COMMENT ON column st_role.description IS 'The description of the role.' ;

COMMENT ON column st_role.is_activity_owner IS 'Indicates whether or not the role has ownerhip of the activity.' ;

COMMENT ON column st_role.can_create_task IS 'Indicates whether or not the role is allowed to create sub-tasks.' ;

COMMENT ON column st_role.can_update_task IS 'Indicates whether or not the role is allowed to update a task.' ;

REVOKE ALL ON table st_role FROM public ;

INSERT INTO st_role (id, name, is_activity_owner, can_create_task, can_update_task) VALUES (1, 'Activity Owner', true, true, true) ;
INSERT INTO st_role (id, name, is_activity_owner, can_create_task, can_update_task) VALUES (2, 'Task Manager', false, true, true) ;
INSERT INTO st_role (id, name, is_activity_owner, can_create_task, can_update_task) VALUES (3, 'Task Updater', false, false, true) ;
INSERT INTO st_role (id, name, is_activity_owner, can_create_task, can_update_task) VALUES (5, 'Task User', false, false, false) ;
