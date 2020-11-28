/*
What, if anything, would we want to track about issues that don't also apply to regular tasks?

    - task_issue__update function
    - add delete to task__delete
        - should delete have different rules than regular?

*/

SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_issue (
    task_id integer NOT NULL,
    probability_id integer,
    severity_id integer,
    workaround_id integer,
    workaround_markup text,
    workaround_html text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_issue_pk PRIMARY KEY ( task_id ) ) ;

ALTER TABLE dt_task_issue OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_issue IS 'Issue specific data.' ;

COMMENT ON COLUMN dt_task_issue.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN dt_task_issue.probability_id IS 'The ID for the probability of triggering the issue.' ;

COMMENT ON COLUMN dt_task_issue.severity_id IS 'The ID for severity of the issue.' ;

COMMENT ON COLUMN dt_task_issue.workaround_id IS 'The ID for the ability to work around the issue.' ;

COMMENT ON COLUMN dt_task_issue.workaround_markup IS 'A description of the workaround.' ;

COMMENT ON COLUMN dt_task_issue.workaround_html IS 'The workaround in HTML format.' ;

COMMENT ON COLUMN dt_task_issue.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_issue.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_issue.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_issue.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk02
    FOREIGN KEY ( probability_id )
    REFERENCES st_issue_probability ( id ) ;

ALTER TABLE dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk03
    FOREIGN KEY ( severity_id )
    REFERENCES st_issue_severity ( id ) ;

ALTER TABLE dt_task_issue
    ADD CONSTRAINT dt_task_issue_fk04
    FOREIGN KEY ( workaround_id )
    REFERENCES st_issue_workaround ( id ) ;

REVOKE ALL ON TABLE dt_task_issue FROM public ;
