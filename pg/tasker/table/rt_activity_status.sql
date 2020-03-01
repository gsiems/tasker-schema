SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_activity_status (
    id serial NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    open_status integer default 0,
    is_enabled boolean DEFAULT true NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT rt_activity_status_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_activity_status_ix1 UNIQUE ( name ),
    CONSTRAINT rt_activity_status_ck1 CHECK ( ( open_status IN (0, 1, 2) ) ) ) ;

ALTER TABLE rt_activity_status OWNER TO tasker_owner ;

COMMENT ON TABLE rt_activity_status IS 'Reference table. Status values for activities.' ;

COMMENT ON column rt_activity_status.id IS 'Unique ID for a status' ;

COMMENT ON column rt_activity_status.name IS 'The name for a status.' ;

COMMENT ON column rt_activity_status.description IS 'The description of the status.' ;

COMMENT ON column rt_activity_status.open_status IS 'Indicates whether or not the status is open (0), closed(2), neither open or closed (1).' ;

COMMENT ON column rt_activity_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON column rt_activity_status.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON column rt_activity_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON column rt_activity_status.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON column rt_activity_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON table rt_activity_status FROM public ;

INSERT INTO rt_activity_status (open_status, name) VALUES (2, 'Closed - Finished') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (2, 'Closed - No longer needed') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (2, 'Closed - Other') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (1, 'Pending') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (1, 'On Hold') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (0, 'Open') ;
INSERT INTO rt_activity_status (open_status, name) VALUES (0, 'Open - Review for closure') ;
