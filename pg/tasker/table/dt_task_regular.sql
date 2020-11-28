
set search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_regular (
    task_id integer NOT NULL,
    desired_start date,
    desired_start_severity_id integer,
    desired_end date,
    desired_end_severity_id integer,
    estimated_start date,
    estimated_end date,
    --time_estimate interval,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_regular_pk PRIMARY KEY ( task_id ) ) ;

ALTER TABLE dt_task_regular OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_regular IS '"Regular" task specific data.' ;

COMMENT ON COLUMN dt_task_regular.task_id IS 'The unique ID for the task.' ;

COMMENT ON COLUMN dt_task_regular.desired_start IS 'The desired date (if any) that work on the task should start.' ;

COMMENT ON COLUMN dt_task_regular.desired_start_severity_id IS 'The severity of not making the desired start date.' ;

COMMENT ON COLUMN dt_task_regular.desired_end IS 'The desired date (if any) for the completion for the task.' ;

COMMENT ON COLUMN dt_task_regular.desired_end_severity_id IS 'The severity of not making the desired end date.' ;

COMMENT ON COLUMN dt_task_regular.estimated_start IS 'The estimated date (if any) that work on the task should start.' ;

COMMENT ON COLUMN dt_task_regular.estimated_end IS 'The estimated date (if any) for the completion for the task.' ;

COMMENT ON COLUMN dt_task_regular.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_regular.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_regular.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_regular.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_regular
    ADD CONSTRAINT dt_task_regular_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_regular
    ADD CONSTRAINT dt_task_regular_fk02
    FOREIGN KEY ( desired_start_severity_id )
    REFERENCES st_date_severity ( id ) ;

ALTER TABLE dt_task_regular
    ADD CONSTRAINT dt_task_regular_fk03
    FOREIGN KEY ( desired_end_severity_id )
    REFERENCES st_date_severity ( id ) ;

REVOKE ALL ON TABLE dt_task_regular FROM public ;
