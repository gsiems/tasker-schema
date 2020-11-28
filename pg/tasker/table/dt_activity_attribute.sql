SET search_path = tasker, pg_catalog ;

CREATE TABLE dt_activity_attribute (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    activity_id integer NOT NULL,
    attribute_type_id integer NOT NULL,
    attribute_text text,
    -- TODO: do we want attribute columns for other data types?
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT dt_activity_attribute_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE dt_activity_attribute OWNER TO tasker_owner ;

COMMENT ON TABLE dt_activity_attribute IS 'Custom attributes for activitys.' ;

COMMENT ON COLUMN dt_activity_attribute.id IS 'The unique ID for an attribute entry.' ;

COMMENT ON COLUMN dt_activity_attribute.activity_id IS 'The ID of the activity.' ;

COMMENT ON COLUMN dt_activity_attribute.attribute_type_id IS 'The ID of attribute type.' ;

COMMENT ON COLUMN dt_activity_attribute.attribute_text IS 'The text of the attribute.' ;

COMMENT ON COLUMN dt_activity_attribute.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity_attribute.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN dt_activity_attribute.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN dt_activity_attribute.updated_dt IS 'The timestamp when the row was most recently updated.' ;

ALTER TABLE dt_activity_attribute
    ADD CONSTRAINT dt_activity_attribute_fk01
    FOREIGN KEY ( activity_id )
    REFERENCES dt_activity ( id ) ;

ALTER TABLE dt_activity_attribute
    ADD CONSTRAINT dt_activity_attribute_fk02
    FOREIGN KEY ( attribute_type_id )
    REFERENCES rt_activity_attribute_type ( id ) ;

REVOKE ALL ON TABLE dt_activity_attribute FROM public ;
