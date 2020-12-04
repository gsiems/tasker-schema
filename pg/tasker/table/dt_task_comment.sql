SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_task_comment (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    parent_id integer,
    task_id integer NOT NULL,
    edition integer DEFAULT 0 NOT NULL,
    owner_id integer NOT NULL,
    created_by integer,
    updated_by integer,
    markup_type_id int2 NOT NULL default 1,
    comment_markup text,
    comment_html text,
    CONSTRAINT dt_task_comment_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE dt_task_comment OWNER TO tasker_owner ;

COMMENT ON TABLE dt_task_comment IS 'Comment on tasks.' ;

COMMENT ON COLUMN dt_task_comment.id IS 'The unique ID for a comment entry.' ;

COMMENT ON COLUMN dt_task_comment.parent_id IS 'The ID of the parent comment (should there be one).' ;

COMMENT ON COLUMN dt_task_comment.task_id IS 'The ID of the task.' ;

COMMENT ON COLUMN dt_task_comment.edition IS 'Indicates the number of edits made to the comment. Intended for use in determining if a comment has been edited between select and update.' ;

COMMENT ON COLUMN dt_task_comment.owner_id IS 'The ID of owner of the comment entry.' ;

COMMENT ON COLUMN dt_task_comment.markup_type_id IS 'The ID of the markup format used for the comment entry.' ;

COMMENT ON COLUMN dt_task_comment.comment_markup IS 'The markup text of the comment entry.' ;

COMMENT ON COLUMN dt_task_comment.comment_html IS 'The HTML form of a comment entry.' ;

COMMENT ON COLUMN dt_task_comment.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_comment.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_task_comment.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_task_comment.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_task_comment
    ADD CONSTRAINT dt_task_comment_fk01
    FOREIGN KEY ( task_id )
    REFERENCES dt_task ( id ) ;

ALTER TABLE dt_task_comment
    ADD CONSTRAINT dt_task_comment_fk02
    FOREIGN KEY ( parent_id )
    REFERENCES dt_task_comment ( id ) ;

ALTER TABLE dt_task_comment
    ADD CONSTRAINT dt_task_comment_fk03
    FOREIGN KEY ( markup_type_id )
    REFERENCES st_markup_type ( id ) ;

ALTER TABLE dt_task_comment
    ADD CONSTRAINT dt_task_comment_fk04
    FOREIGN KEY ( owner_id )
    REFERENCES dt_user ( id ) ;

REVOKE ALL ON TABLE dt_task_comment FROM public ;
