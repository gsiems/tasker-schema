SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_task_type (
    id serial NOT NULL,
    category_id integer NOT NULL default 1,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    markup_type_id integer,
    template_markup text,
    template_html text,
    is_enabled boolean DEFAULT true NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT rt_task_type_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_task_type_ix1 UNIQUE ( category_id, name ) ) ;

ALTER TABLE rt_task_type OWNER TO tasker_owner ;

COMMENT ON TABLE rt_task_type IS 'Reference table. Types of tasks.' ;

COMMENT ON COLUMN rt_task_type.id IS 'Unique ID for a task type' ;

COMMENT ON COLUMN rt_task_type.name IS 'The name for a task type.' ;

COMMENT ON COLUMN rt_task_type.description IS 'The description of a task type.' ;

COMMENT ON COLUMN rt_task_type.category_id IS 'The category that the task type belongs to.' ;

COMMENT ON COLUMN rt_task_type.markup_type_id IS 'The ID of the markup format used for the template_markup column.' ;

COMMENT ON COLUMN rt_task_type.template_markup IS 'The optional template to use when creating a new task.' ;

COMMENT ON COLUMN rt_task_type.template_html IS 'The template in HTML format.' ;

COMMENT ON COLUMN rt_task_type.is_enabled IS 'Indicates whether or not the task type is available for use.' ;

COMMENT ON COLUMN rt_task_type.created_by IS 'The ID of the individual that created the row (ref pt_user).' ;

COMMENT ON COLUMN rt_task_type.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN rt_task_type.updated_by IS 'The ID of the individual that most recently updated the row (ref pt_user).' ;

COMMENT ON COLUMN rt_task_type.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE rt_task_type FROM public ;

ALTER TABLE rt_task_type
    ADD CONSTRAINT rt_task_type_fk01
    FOREIGN KEY ( category_id )
    REFERENCES st_task_category ( id ) ;

INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Action item', 'Task type for an assigned action item.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Administration', 'Task type for administrative actions.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Corrective action', 'Task type for performing corrective actions.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Discovery', 'Task type for performing discovery.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Event', 'Task type for an event.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Issue management', 'Task type for evaluating/managing issues');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Maintenance', 'Task type for performing maintenance tasks');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Meeting preparation', 'Task type for setting up/preparing for meetings');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Other', NULL);
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Personal Project', 'Task type for a personal project');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Project management', 'Task type for overhead of actually managing projects');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Requirement development', 'Task type for developing requirements.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Requirement implementation', 'Task type for implementing a requirement.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Research', 'Task type for performing research.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Test development', 'Task type for developing tests');
INSERT INTO rt_task_type (category_id, name, description) VALUES (1, 'Testing', 'Task type for performing tests');

INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Business', 'Task type for business requirements');
INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Functional', 'Task type for functional requirements');
INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Process', 'Task type for process requirements');
INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Style', 'Task type for "Having to do with the appearance (vs. substance) of" requirements.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Technical', 'Task type for technical requirements');
INSERT INTO rt_task_type (category_id, name, description) VALUES (2, 'Other', 'Task type for other kinds of requirements');

INSERT INTO rt_task_type (category_id, name, description) VALUES (3, 'Support request', 'Task type for support request issues');
INSERT INTO rt_task_type (category_id, name, description) VALUES (3, 'Defect', 'A problem that prevents or impaires current, or required, functionality.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (3, 'Risk', 'A potential problem that may prevent or impair current, or required, functionality or that may otherwise endanger the activity.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (3, 'Other', 'Task type for other kinds of issues.');

INSERT INTO rt_task_type (category_id, name, description) VALUES (4, 'Meeting', 'Task type for conducting/attending meetings.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (4, 'Pre-meeting meeting', 'Task type for conducting/attending meetings prior to/in preparation for a larger meeting.');
INSERT INTO rt_task_type (category_id, name, description) VALUES (4, 'Event', 'Task type for an event.');

--INSERT INTO rt_task_type (category_id, name, description) VALUES (5, 'Administration', 'Task type for administrative actions.');
--INSERT INTO rt_task_type (category_id, name, description) VALUES (5, 'Maintenance', 'Task type for performing maintenance tasks');
--INSERT INTO rt_task_type (category_id, name, description) VALUES (5, 'Testing', 'Task type for performing tests');
