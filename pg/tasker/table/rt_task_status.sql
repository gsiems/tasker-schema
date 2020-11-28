SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_task_status (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    category_id integer default 0,
    open_status integer default 0,
    is_enabled boolean DEFAULT true NOT NULL,
    created_by integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_by integer,
    updated_dt timestamp with time zone,
    CONSTRAINT rt_task_status_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_task_status_ix1 UNIQUE ( category_id, name ),
    CONSTRAINT rt_task_status_ck1 CHECK ( ( open_status IN (0, 1, 2) ) ) ) ;

ALTER TABLE rt_task_status OWNER TO tasker_owner ;

COMMENT ON TABLE rt_task_status IS 'Reference table. Status values for tasks.' ;

COMMENT ON COLUMN rt_task_status.id IS 'Unique ID for a status' ;

COMMENT ON COLUMN rt_task_status.name IS 'The name for a status.' ;

COMMENT ON COLUMN rt_task_status.description IS 'The description of the status.' ;

COMMENT ON COLUMN rt_task_status.category_id IS 'Indicates category of task that the status is for.' ;

COMMENT ON COLUMN rt_task_status.open_status IS 'Indicates whether or not the status is open (0), closed(2), neither open or closed (1).' ;

COMMENT ON COLUMN rt_task_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN rt_task_status.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN rt_task_status.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE rt_task_status FROM public ;

-- "Regular" tasks
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 2, 'Closed - Cannot implement') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 2, 'Closed - Finished') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 2, 'Closed - No longer needed') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 2, 'Closed - Other') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 1, 'Draft') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 1, 'Draft - Review for opening') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 1, 'On Hold') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 0, 'Open') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (1, 0, 'Open - Review for closure') ;

-- Requirement tasks
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 2, 'Closed - Cannot implement') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 2, 'Closed - Finished') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 2, 'Closed - No longer needed') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 2, 'Closed - Out of scope') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 2, 'Closed - Other') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 1, 'Draft') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 1, 'Draft - Review for opening') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 1, 'On Hold') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 0, 'Open') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (2, 0, 'Open - Review for closure') ;

-- Issue tasks
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Can not fix') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Can not reproduce') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Finished') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - No longer an issue') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Out of scope') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Will not fix') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 2, 'Closed - Other') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 1, 'Draft') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 1, 'Draft - Review for opening') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 1, 'On Hold') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 0, 'Open') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (3, 0, 'Open - Review for closure') ;

-- Meeting tasks
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (4, 2, 'Closed - Finished') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (4, 2, 'Closed - Cancelled') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (4, 1, 'Pending') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (4, 1, 'On Hold') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (4, 0, 'Open') ;

-- Recurring tasks
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 2, 'Closed - Finished') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 2, 'Closed - No longer needed') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 2, 'Closed - Other') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 1, 'Pending') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 1, 'On Hold') ;
INSERT INTO rt_task_status (category_id, open_status, name) VALUES (5, 0, 'Open') ;
