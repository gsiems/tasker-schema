SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_journal (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    task_id integer NOT NULL,
    edition integer DEFAULT 0 NOT NULL,
    user_id integer NOT NULL,
    markup_type_id integer NOT NULL default 1,
    time_spent integer,
    journal_date date,
    journal_markup text,
    journal_html text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_task_journal_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE dt_task_journal OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_journal IS 'Journal entries for tasks.' ;

COMMENT ON COLUMN dt_task_journal.id IS 'The unique ID for a journal entry.' ;

COMMENT ON COLUMN dt_task_journal.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN dt_task_journal.edition IS 'Indicates the number of edits made to the journal entry. Intended for use in determining if an entry has been edited between select and update.' ;

COMMENT ON COLUMN dt_task_journal.user_id IS 'The ID of owner of the journal entry.' ;

COMMENT ON COLUMN dt_task_journal.markup_type_id IS 'The ID of the markup format used for the journal entry.' ;

COMMENT ON COLUMN dt_task_journal.time_spent IS 'The amount of time spent in minutes.' ;

COMMENT ON COLUMN dt_task_journal.journal_date IS 'The date that the journal entry covers.' ;

COMMENT ON COLUMN dt_task_journal.journal_markup IS 'The markup text of the journal entry.' ;

COMMENT ON COLUMN dt_task_journal.journal_html IS 'The HTML form of a journal entry.' ;

COMMENT ON COLUMN dt_task_journal.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_journal.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_journal.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_journal.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk02
    FOREIGN KEY ( user_id )
    REFERENCES dt_user ( id ) ;

ALTER TABLE dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk03
    FOREIGN KEY ( markup_type_id )
    REFERENCES st_markup_type ( id ) ;

REVOKE ALL ON TABLE dt_task_journal FROM public ;
