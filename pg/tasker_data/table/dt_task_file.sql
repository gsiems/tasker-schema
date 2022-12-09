CREATE TABLE tasker_data.dt_task_file (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    task_id integer NOT NULL,
    edition integer DEFAULT 0 NOT NULL,
    comment_id integer,
    journal_id integer,
    filesize integer,
    created_by_id integer,
    updated_by_id integer,
    filename character varying ( 100 ),
    content_type character varying ( 100 ),
    content bytea,
    CONSTRAINT dt_task_file_pk PRIMARY KEY ( id )
);

ALTER TABLE tasker_data.dt_task_file OWNER TO tasker_owner;

COMMENT ON TABLE tasker_data.dt_task_file IS 'Files that have been uploaded as either attachements or as display images for tasks.';

COMMENT ON COLUMN tasker_data.dt_task_file.id IS 'Unique ID for a file.';

COMMENT ON COLUMN tasker_data.dt_task_file.task_id IS 'The task that the file is attached to.';

COMMENT ON COLUMN tasker_data.dt_task_file.edition IS 'Indicates the number of edits made to the file. Intended for use in determining if a file record has been edited between select and update.' ;

COMMENT ON COLUMN tasker_data.dt_task_file.comment_id IS 'The task comment (if any) that the file is attached to.';

COMMENT ON COLUMN tasker_data.dt_task_file.journal_id IS 'The task journal (if any) the file is attached to.';

COMMENT ON COLUMN tasker_data.dt_task_file.filesize IS 'The size of the file in bytes.';

COMMENT ON COLUMN tasker_data.dt_task_file.filename IS 'The filename of the file.';

COMMENT ON COLUMN tasker_data.dt_task_file.content_type IS 'The MIME Content-Type of the file.';

COMMENT ON COLUMN tasker_data.dt_task_file.content IS 'The content of the file.';

COMMENT ON COLUMN tasker_data.dt_task_file.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_file.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_task_file.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_file.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.dt_task_file
    ADD CONSTRAINT dt_task_file_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_file
    ADD CONSTRAINT dt_task_file_fk02
    FOREIGN KEY ( comment_id )
    REFERENCES tasker_data.dt_task_comment ( id ) ;

ALTER TABLE tasker_data.dt_task_file
    ADD CONSTRAINT dt_task_file_fk03
    FOREIGN KEY ( journal_id )
    REFERENCES tasker_data.dt_task_journal ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_file FROM public ;
