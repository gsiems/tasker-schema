SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_activity_category (
    id serial NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    is_enabled boolean DEFAULT true NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT rt_activity_category_pk PRIMARY KEY ( id ) ) ;

ALTER TABLE rt_activity_category OWNER TO tasker_owner ;

COMMENT ON TABLE rt_activity_category IS 'Reference table. Categories for activities.' ;

COMMENT ON column rt_activity_category.id IS 'Unique ID for a category' ;

COMMENT ON column rt_activity_category.name IS 'The name for a category.' ;

COMMENT ON column rt_activity_category.description IS 'The description of the category.' ;

COMMENT ON column rt_activity_category.is_enabled IS 'Indicates whether or not the category is available for use.' ;

COMMENT ON column rt_activity_category.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column rt_activity_category.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON column rt_activity_category.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON column rt_activity_category.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON table rt_activity_category FROM public ;

INSERT INTO rt_activity_category (name, is_enabled) VALUES ('Default', true) ;
