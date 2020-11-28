set search_path = tasker, pg_catalog ;

CREATE TABLE dt_activity (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    parent_id integer,
    visibility_id integer NOT NULL,
    category_id integer,
    status_id integer NOT NULL,
    priority_id integer NOT NULL,
    markup_type_id integer,
    activity_name character varying ( 200 ) NOT NULL,
    description_markup text,
    description_html text,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_activity_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_activity_ck1 check ( ( id <> parent_id ) ) ) ;

ALTER TABLE dt_activity OWNER TO tasker_owner ;

COMMENT ON TABLE dt_activity IS 'Activities that act as containers for tasks.' ;

COMMENT ON COLUMN dt_activity.id IS 'The unique ID for the activity.' ;

COMMENT ON COLUMN dt_activity.parent_id IS 'The ID of the parent activity (if any).' ;

COMMENT ON COLUMN dt_activity.visibility_id IS 'Indicates the "visibility" of the activity.';

COMMENT ON COLUMN dt_activity.category_id IS 'Indicates the category of activity.';

COMMENT ON COLUMN dt_activity.status_id IS 'The status of the activity.' ;

COMMENT ON COLUMN dt_activity.priority_id IS 'The priority of the activity.' ;

COMMENT ON COLUMN dt_activity.markup_type_id IS 'The ID of the markup format used for the description_markup column.' ;

COMMENT ON COLUMN dt_activity.description_markup IS 'A description of the activity and/or the purpose of the activity.' ;

COMMENT ON COLUMN dt_activity.description_html IS 'The description in HTML format.' ;

COMMENT ON COLUMN dt_activity.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_activity.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity.updated_dt IS 'The timestamp when the row was most recently updated.' ;

CREATE INDEX dt_activity_idx1 ON dt_activity ( parent_id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk01
    FOREIGN KEY ( parent_id )
    REFERENCES dt_activity ( id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk02
    FOREIGN KEY ( visibility_id )
    REFERENCES st_visibility ( id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk03
    FOREIGN KEY ( category_id )
    REFERENCES rt_activity_category ( id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk04
    FOREIGN KEY ( status_id )
    REFERENCES rt_activity_status ( id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk05
    FOREIGN KEY ( priority_id )
    REFERENCES st_ranking ( id ) ;

ALTER TABLE dt_activity
    ADD CONSTRAINT dt_activity_fk06
    FOREIGN KEY ( markup_type_id )
    REFERENCES st_markup_type ( id ) ;

REVOKE ALL ON TABLE dt_activity FROM public ;
