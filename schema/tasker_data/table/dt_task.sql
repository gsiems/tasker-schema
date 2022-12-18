/*
task is THE fundamental base unit
activity is a top-level task
activity can have sub-activities
activity "contains" tasks
activity_id is required
    -- for activity tasks: id == activity_id

*/

CREATE TABLE tasker_data.dt_task (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    parent_id integer,
    edition integer DEFAULT 0 NOT NULL,
    activity_id integer NOT NULL,
    task_name text NOT NULL,
    owner_id integer,
    assignee_id integer,
    task_type_id integer NOT NULL,
    time_estimate integer,
    visibility_id int2 NOT NULL,
    markup_type_id int2 NOT NULL default 1,
    status_id int2,
    priority_id int2,
    desired_start_importance_id int2,
    desired_end_importance_id int2,
    desired_start date,
    desired_end date,
    estimated_start date,
    estimated_end date,
    actual_start date,
    actual_end date,
    description_markup text,
    description_html text,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT dt_task_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_task_ck1 CHECK ( id <> parent_id ) ) ;

CREATE INDEX dt_task_idx1 ON tasker_data.dt_task ( parent_id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk01
    FOREIGN KEY ( parent_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk02
    FOREIGN KEY ( owner_id )
    REFERENCES tasker_data.dt_user ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk03
    FOREIGN KEY ( assignee_id )
    REFERENCES tasker_data.dt_user ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk04
    FOREIGN KEY ( task_type_id )
    REFERENCES tasker_data.rt_task_type ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk05
    FOREIGN KEY ( visibility_id )
    REFERENCES tasker_data.st_visibility ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk06
    FOREIGN KEY ( status_id )
    REFERENCES tasker_data.rt_task_status ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk07
    FOREIGN KEY ( priority_id )
    REFERENCES tasker_data.st_ranking ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk08
    FOREIGN KEY ( markup_type_id )
    REFERENCES tasker_data.st_markup_type ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk09
    FOREIGN KEY ( desired_start_importance_id )
    REFERENCES tasker_data.st_date_importance ( id ) ;

ALTER TABLE tasker_data.dt_task
    ADD CONSTRAINT dt_task_fk10
    FOREIGN KEY ( desired_end_importance_id )
    REFERENCES tasker_data.st_date_importance ( id ) ;

ALTER TABLE tasker_data.dt_task OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task IS 'Tasks.' ;

COMMENT ON COLUMN tasker_data.dt_task.id IS 'The unique ID for the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.parent_id IS 'The ID of the parent task (if any).' ;

COMMENT ON COLUMN tasker_data.dt_task.activity_id IS 'The ID of the activity that the task belongs to. For tasks that are activities, the activity ID equals the task ID.' ;

COMMENT ON COLUMN tasker_data.dt_task.owner_id IS 'The ID of the user that owns the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.assignee_id IS 'The ID of the user that the task is assigned to.' ;

COMMENT ON COLUMN tasker_data.dt_task.edition IS 'Indicates the number of edits made to the task. Intended for use in determining if a task has been edited between select and update.' ;

COMMENT ON COLUMN tasker_data.dt_task.task_type_id IS 'Indicates the type of task.' ;

COMMENT ON COLUMN tasker_data.dt_task.visibility_id IS 'Indicates the visibility of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.status_id IS 'The status of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.priority_id IS 'The priority of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.markup_type_id IS 'The ID of the markup format used for the description_markup column.' ;

COMMENT ON COLUMN tasker_data.dt_task.desired_start_importance_id IS 'The importance of not making the desired start date.' ;

COMMENT ON COLUMN tasker_data.dt_task.desired_end_importance_id IS 'The importance of not making the desired end date.' ;

COMMENT ON COLUMN tasker_data.dt_task.task_name IS 'The name for the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.desired_start IS 'The desired date (if any) that work on the task should start.' ;

COMMENT ON COLUMN tasker_data.dt_task.desired_end IS 'The desired date (if any) for the completion for the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.estimated_start IS 'The estimated date (if any) that work on the task should start.' ;

COMMENT ON COLUMN tasker_data.dt_task.estimated_end IS 'The estimated date (if any) for the completion for the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.actual_start IS 'The actual date that work on the task was started.' ;

COMMENT ON COLUMN tasker_data.dt_task.actual_end IS 'The actual date that the task was finished.' ;

COMMENT ON COLUMN tasker_data.dt_task.time_estimate IS 'The estimated time that it should take to implement the task in minutes.' ;

COMMENT ON COLUMN tasker_data.dt_task.description_markup IS 'A description of the task and/or the purpose of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task.description_html IS 'The description in HTML format.' ;

COMMENT ON COLUMN tasker_data.dt_task.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_task.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task.updated_dt IS 'The timestamp when the row was most recently updated.' ;