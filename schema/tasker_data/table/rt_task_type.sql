CREATE TABLE tasker_data.rt_task_type (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    task_category_id int2 NOT NULL,
    markup_type_id int2 NOT NULL default 1,
    name text NOT NULL,
    description text,
    template_markup text,
    template_html text,
    is_default boolean NOT NULL default false,
    is_enabled boolean DEFAULT true NOT NULL,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT rt_task_type_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_task_type_nk UNIQUE ( task_category_id, name ) ) ;

ALTER TABLE tasker_data.rt_task_type
    ADD CONSTRAINT rt_task_type_fk01
    FOREIGN KEY ( task_category_id )
    REFERENCES tasker_data.st_task_category ( id ) ;

ALTER TABLE tasker_data.rt_task_type
    ADD CONSTRAINT rt_task_type_fk02
    FOREIGN KEY ( markup_type_id )
    REFERENCES tasker_data.st_markup_type ( id ) ;

ALTER TABLE tasker_data.rt_task_type OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_task_type IS 'Reference table. Types of tasks.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.id IS 'Unique ID for a task type' ;

COMMENT ON COLUMN tasker_data.rt_task_type.task_category_id IS 'The category that the task type belongs to.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.markup_type_id IS 'The ID of the markup format used for the template_markup column.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.name IS 'The name for a task type.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.description IS 'The description of a task type.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.template_markup IS 'The optional template to use when creating a new task.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.template_html IS 'The template in HTML format.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.is_enabled IS 'Indicates whether or not the task type is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.created_by_id IS 'The ID of the individual that created the row (ref pt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_type.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_task_type.updated_by_id IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'Task', 'Action item', 'Task type for an assigned action item.' ),
                ( 'Task', 'Administration', 'Task type for administrative actions.' ),
                ( 'Task', 'Corrective action', 'Task type for performing corrective actions.' ),
                ( 'Task', 'Discovery', 'Task type for performing discovery.' ),
                ( 'Task', 'Event', 'Task type for an event.' ),
                ( 'Task', 'Issue management', 'Task type for evaluating/managing issues' ),
                ( 'Task', 'Maintenance', 'Task type for performing maintenance tasks' ),
                ( 'Task', 'Meeting preparation', 'Task type for setting up/preparing for meetings' ),
                ( 'Task', 'Other', '' ),
                ( 'Task', 'Personal Project', 'Task type for a personal project' ),
                ( 'Task', 'Project management', 'Task type for overhead of actually managing projects' ),
                ( 'Task', 'Requirement development', 'Task type for developing requirements.' ),
                ( 'Task', 'Requirement implementation', 'Task type for implementing a requirement.' ),
                ( 'Task', 'Research', 'Task type for performing research.' ),
                ( 'Task', 'Test development', 'Task type for developing tests' ),
                ( 'Task', 'Testing', 'Task type for performing tests' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'Requirement', 'Business', 'Task type for business requirements' ),
                ( 'Requirement', 'Functional', 'Task type for functional requirements' ),
                ( 'Requirement', 'Process', 'Task type for process requirements' ),
                ( 'Requirement', 'Style', 'Task type for "Having to do with the appearance (vs. substance) of" requirements.' ),
                ( 'Requirement', 'Technical', 'Task type for technical requirements' ),
                ( 'Requirement', 'Other', 'Task type for other kinds of requirements' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'Issue', 'Defect', 'A problem that prevents or impaires current, or required, functionality.' ),
                ( 'Issue', 'Enhancement', 'Task type for requesting an improvement to the current functionality.' ),
                ( 'Issue', 'New feature', 'Task type for requesting a new feature or capability.' ),
                ( 'Issue', 'Other', 'Task type for other kinds of issues.' ),
                ( 'Issue', 'Risk', 'A potential problem that may prevent or impair current, or required, functionality or that may otherwise endanger the activity.' ),
                ( 'Issue', 'Support request', 'Task type for support request issues' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'Meeting', 'Meeting', 'Task type for conducting/attending meetings.' ),
                ( 'Meeting', 'Pre-meeting meeting', 'Task type for conducting/attending meetings prior to/in preparation for a larger meeting.' ),
                ( 'Meeting', 'Event', 'Task type for an event.' ),
                ( 'Meeting', 'Ad hoc', 'Special purpose meeting (not specified)' ),
                ( 'Meeting', 'Kickoff', 'Activity start' ),
                ( 'Meeting', 'Management', '' ),
                ( 'Meeting', 'Staff', 'Meeting between a manager and their staff' ),
                ( 'Meeting', 'One-on-one', 'Meeting between two individuals' ),
                ( 'Meeting', 'Stand-up', '' ),
                ( 'Meeting', 'Status', '' ),
                ( 'Meeting', 'Team', '' ),
                ( 'Meeting', 'Work', 'Meeting (not otherwise specified) which produces a product or result.' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'Activity', 'Default', 'Default activity type.' ),
                ( 'Activity', 'Project', 'Activity type for projects.' ),
                ( 'Activity', 'Research project', 'Activity type for research projects.' ),
                ( 'Activity', 'Support', 'Activity type for support activities.' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;

INSERT INTO tasker_data.rt_task_type (
        task_category_id,
        name,
        description )
    SELECT stc.id AS task_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_task_category stc
        JOIN (
            VALUES
                ( 'PIP', 'Milestone', '' ),
                ( 'PIP', 'Phase', '' ),
                ( 'PIP', 'Release', '' ),
                ( 'PIP', 'Revision', '' ),
                ( 'PIP', 'Scrum Spike', '' ),
                ( 'PIP', 'Scrum Sprint', '' ),
                ( 'PIP', 'Version', '' )
            ) AS dat ( category_name, name, description )
            ON ( dat.category_name = stc.name ) ;
