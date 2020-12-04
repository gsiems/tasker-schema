SET search_path = tasker, pg_catalog ;

CREATE TABLE st_task_category (
    id int2 NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT st_task_category_pk PRIMARY KEY ( id ),
    CONSTRAINT st_task_category_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_task_category OWNER TO tasker_owner ;

COMMENT ON TABLE st_task_category IS 'Reference table. Broad categories that tasks fall into.' ;

COMMENT ON COLUMN st_task_category.id IS 'Unique ID for a task category.' ;

COMMENT ON COLUMN st_task_category.name IS 'The name for a task category.' ;

COMMENT ON COLUMN st_task_category.description IS 'The description of a task category.' ;

REVOKE ALL ON TABLE st_task_category FROM public ;

INSERT INTO st_task_category (id, name, description) VALUES (1, 'Task', 'Task category for tasks that do not fall in any other category.');
INSERT INTO st_task_category (id, name, description) VALUES (2, 'Requirement', 'Special task category for requirements.');
INSERT INTO st_task_category (id, name, description) VALUES (3, 'Issue', 'Special task category for issues.');
INSERT INTO st_task_category (id, name, description) VALUES (4, 'Meeting', 'Special task category for meetings.');
INSERT INTO st_task_category (id, name, description) VALUES (5, 'Activity', 'Special task category for activities.');
INSERT INTO st_task_category (id, name, description) VALUES (6, 'PIP', 'Special task category for Points or Intervals of Progress.');
