CREATE TABLE tasker_data.dt_task_journal (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    task_id integer NOT NULL,
    edition integer DEFAULT 0 NOT NULL,
    owner_id integer NOT NULL,
    time_spent integer,
    journal_date date,
    created_by_id integer,
    updated_by_id integer,
    markup_type_id int2 NOT NULL default 1,
    journal_markup text,
    journal_html text,
    CONSTRAINT dt_task_journal_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE tasker_data.dt_task_journal OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.dt_task_journal IS 'Journal entries for tasks.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.id IS 'The unique ID for a journal entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.edition IS 'Indicates the number of edits made to the journal entry. Intended for use in determining if an entry has been edited between select and update.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.owner_id IS 'The ID of owner of the journal entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.markup_type_id IS 'The ID of the markup format used for the journal entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.time_spent IS 'The amount of time spent in minutes.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.journal_date IS 'The date that the journal entry covers.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.journal_markup IS 'The markup text of the journal entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.journal_html IS 'The HTML form of a journal entry.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.dt_task_journal.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE tasker_data.dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk01
    FOREIGN KEY ( task_id )
    REFERENCES tasker_data.dt_task ( id ) ;

ALTER TABLE tasker_data.dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk02
    FOREIGN KEY ( owner_id )
    REFERENCES tasker_data.dt_user ( id ) ;

ALTER TABLE tasker_data.dt_task_journal
    ADD CONSTRAINT dt_task_journal_fk03
    FOREIGN KEY ( markup_type_id )
    REFERENCES tasker_data.st_markup_type ( id ) ;

REVOKE ALL ON TABLE tasker_data.dt_task_journal FROM public ;
