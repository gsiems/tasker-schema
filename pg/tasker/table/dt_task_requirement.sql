/*
What, if anything, would we want to track about requirements that don't also apply to regular tasks?


    - task_requirement__update function
    - add delete to task__delete

*/


set search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_requirement (
    task_id integer NOT NULL,
    --desired_start date,
    --desired_end date,
    --estimated_start date,
    --estimated_end date,
    --actual_start date,
    --actual_end date,
    --time_estimate interval,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_requirement_pk PRIMARY KEY ( task_id ) ) ;

ALTER TABLE dt_task_requirement OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_requirement IS 'Requirement Tasks.' ;

COMMENT ON COLUMN dt_task_requirement.task_id IS 'The unique ID for the task.' ;

--COMMENT ON COLUMN dt_task_requirement.desired_start IS 'The desired date (if any) that work on the task should start.' ;
--
--COMMENT ON COLUMN dt_task_requirement.desired_end IS 'The desired date (if any) for the completion for the task.' ;
--
--COMMENT ON COLUMN dt_task_requirement.estimated_start IS 'The estimated date (if any) that work on the task should start.' ;
--
--COMMENT ON COLUMN dt_task_requirement.estimated_end IS 'The estimated date (if any) for the completion for the task.' ;
--
--COMMENT ON COLUMN dt_task_requirement.actual_start IS 'The actual date that work on the task was started.' ;
--
--COMMENT ON COLUMN dt_task_requirement.actual_end IS 'The actual date that the task was finished.' ;
--
--COMMENT ON COLUMN dt_task_requirement.time_estimate IS 'The estimated time that it should take to implement the task.' ;
--
--COMMENT ON COLUMN dt_task_requirement.description_markup IS 'A description of the task and/or the purpose of the task.' ;
--
--COMMENT ON COLUMN dt_task_requirement.description_html IS 'The description in HTML format.' ;

COMMENT ON COLUMN dt_task_requirement.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_requirement.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_requirement.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_requirement.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_requirement
    ADD CONSTRAINT dt_task_regular_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

REVOKE ALL ON TABLE dt_task_requirement FROM public ;
