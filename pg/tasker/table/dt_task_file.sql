SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_file (
    id integer NOT NULL,
    task_id integer NOT NULL,
    comment_id integer,
    journal_id integer,
    filesize integer,
    filename character varying(100),
    content_type character varying(100),
    content bytea,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_file_pk PRIMARY KEY ( id )
);

ALTER TABLE dt_task_file OWNER TO tasker_owner;

COMMENT ON TABLE dt_task_file IS 'Files that have been uploaded as either attachements or as display images for tasks.';

COMMENT ON COLUMN dt_task_file.id IS 'Unique ID for a file.';

COMMENT ON COLUMN dt_task_file.task_id IS 'The task that the file is attached to.';

COMMENT ON COLUMN dt_task_file.comment_id IS 'The task comment (if any) that the file is attached to.';

COMMENT ON COLUMN dt_task_file.journal_id IS 'The task journal (if any) the file is attached to.';

COMMENT ON COLUMN dt_task_file.filesize IS 'The size of the file in bytes.';

COMMENT ON COLUMN dt_task_file.filename IS 'The filename of the file.';

COMMENT ON COLUMN dt_task_file.content_type IS 'The MIME Content-Type of the file.';

COMMENT ON COLUMN dt_task_file.content IS 'The content of the file.';

COMMENT ON column dt_task_file.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column dt_task_file.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON column dt_task_file.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON column dt_task_file.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_file
    ADD CONSTRAINT dt_task_file_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_file
    ADD CONSTRAINT dt_task_file_fk02
    FOREIGN KEY ( comment_id )
    REFERENCES dt_task_comment ( id ) ;

ALTER TABLE dt_task_file
    ADD CONSTRAINT dt_task_file_fk03
    FOREIGN KEY ( journal_id )
    REFERENCES dt_task_journal ( id ) ;

REVOKE ALL ON table dt_task FROM public ;
