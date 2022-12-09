CREATE TABLE tasker_data.st_association_type (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT st_association_type_pk PRIMARY KEY ( id ),
    CONSTRAINT st_association_type_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_association_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_association_type IS 'Reference table. Types of associations between tasks.' ;

COMMENT ON COLUMN tasker_data.st_association_type.id IS 'Unique ID for a type of task association.' ;

COMMENT ON COLUMN tasker_data.st_association_type.name IS 'The name for a type of task association.' ;

COMMENT ON COLUMN tasker_data.st_association_type.description IS 'The description of a task associations.' ;

REVOKE ALL ON TABLE tasker_data.st_association_type FROM public ;

INSERT INTO tasker_data.st_association_type (id, name, description) VALUES (1, 'Association', 'Task has an association with another task.');
INSERT INTO tasker_data.st_association_type (id, name, description) VALUES (2, 'Dependency', 'Task has a dependency on another task.');
INSERT INTO tasker_data.st_association_type (id, name, description) VALUES (3, 'Duplicate', 'Task is a duplicate of another task.');
