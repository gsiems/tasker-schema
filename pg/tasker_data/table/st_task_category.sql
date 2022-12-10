CREATE TABLE tasker_data.st_task_category (
    id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    CONSTRAINT st_task_category_pk PRIMARY KEY ( id ),
    CONSTRAINT st_task_category_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.st_task_category OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.st_task_category IS 'Reference table. Broad categories that tasks fall into.' ;

COMMENT ON COLUMN tasker_data.st_task_category.id IS 'Unique ID for a task category.' ;

COMMENT ON COLUMN tasker_data.st_task_category.name IS 'The name for a task category.' ;

COMMENT ON COLUMN tasker_data.st_task_category.description IS 'The description of a task category.' ;

COMMENT ON COLUMN tasker_data.st_task_category.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.st_task_category.is_enabled IS 'Indicates whether or not the row is available for new use.' ;

INSERT INTO tasker_data.st_task_category (
        name,
        description )
    VALUES
        ( 'Task', 'Task category for tasks that do not fall in any other category.' ),
        ( 'Requirement', 'Special task category for requirements.' ),
        ( 'Issue', 'Special task category for issues.' ),
        ( 'Meeting', 'Special task category for meetings.' ),
        ( 'Activity', 'Special task category for activities.' ),
        ( 'PIP', 'Special task category for "Points or Intervals of Progress".' ) ;
