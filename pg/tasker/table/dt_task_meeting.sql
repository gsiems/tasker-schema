SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_meeting (
    task_id integer NOT NULL,
    meeting_location varchar ( 100 ),
    agenda_markup text,
    agenda_html text,
    minutes_markup text,
    minutes_html text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_meeting_pk PRIMARY KEY ( task_id ) ) ;

ALTER TABLE dt_task_meeting OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_meeting IS 'Meeting specific data.' ;

COMMENT ON COLUMN dt_task_meeting.task_id IS 'The unique ID for the task.' ;

COMMENT ON COLUMN dt_task_meeting.meeting_location IS 'The location of the meeting.' ;

COMMENT ON COLUMN dt_task_meeting.agenda_markup IS 'The markup text of the meeting agenda.' ;

COMMENT ON COLUMN dt_task_meeting.agenda_html IS 'The HTML form of the meeting agenda.' ;

COMMENT ON COLUMN dt_task_meeting.minutes_markup IS 'The markup text of the meeting minutes.' ;

COMMENT ON COLUMN dt_task_meeting.minutes_html IS 'The HTML form of the meeting minutes.' ;

COMMENT ON COLUMN dt_task_meeting.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_meeting.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_meeting.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_meeting.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_meeting
    ADD CONSTRAINT dt_task_meeting_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

REVOKE ALL ON TABLE dt_task_meeting FROM public ;
