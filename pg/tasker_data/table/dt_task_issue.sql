/*
What, if anything, would we want to track about issues that don't also apply to regular tasks?

    - task_issue__update function
    - add delete to task__delete
        - should delete have different rules than regular?

*/

CREATE TABLE tasker_data.dt_task_issue (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    task_id integer NOT NULL,
    created_by integer,
    updated_by integer,
    probability_id int2,
    severity_id int2,
    workaround_id int2,
    workaround_markup text,
    workaround_html text,
    CONSTRAINT dt_task_issue_pk PRIMARY KEY ( task_id ) ) ;

ALTER TABLE tasker_data.dt_task_issue OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task_issue IS 'Issue specific data.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.probability_id IS 'The ID for the probability of triggering the issue.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.severity_id IS 'The ID for severity of the issue.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.workaround_id IS 'The ID for the ability to work around the issue.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.workaround_markup IS 'A description of the workaround.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.workaround_html IS 'The workaround in HTML format.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_issue.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk02
    FOREIGN KEY ( probability_id )
    REFERENCES tasker_data.st_issue_probability ( id ) ;

ALTER TABLE tasker_data.dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk03
    FOREIGN KEY ( severity_id )
    REFERENCES tasker_data.st_issue_severity ( id ) ;

ALTER TABLE tasker_data.dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk04
    FOREIGN KEY ( workaround_id )
    REFERENCES tasker_data.st_issue_workaround ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_issue FROM public ;
