CREATE TABLE tasker_data.st_task_category (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT st_task_category_pk PRIMARY KEY ( id ),
    CONSTRAINT st_task_category_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_task_category OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_task_category IS 'Reference table. Broad categories that tasks fall into.' ;

COMMENT ON COLUMN tasker_data.st_task_category.id IS 'Unique ID for a task category.' ;

COMMENT ON COLUMN tasker_data.st_task_category.name IS 'The name for a task category.' ;

COMMENT ON COLUMN tasker_data.st_task_category.description IS 'The description of a task category.' ;

REVOKE ALL ON TABLE tasker_data.st_task_category FROM public ;

INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (1, 'Task', 'Task category for tasks that do not fall in any other category.');
INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (2, 'Requirement', 'Special task category for requirements.');
INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (3, 'Issue', 'Special task category for issues.');
INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (4, 'Meeting', 'Special task category for meetings.');
INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (5, 'Activity', 'Special task category for activities.');
INSERT INTO tasker_data.st_task_category (id, name, description) VALUES (6, 'PIP', 'Special task category for "Points or Intervals of Progress".');
