CREATE TABLE tasker_data.rt_task_status (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    created_by_id integer,
    updated_by_id integer,
    open_status int2 default 0,
    is_enabled boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT rt_task_status_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_task_status_nk UNIQUE ( name ),
    CONSTRAINT rt_task_status_ck1 CHECK ( ( open_status IN (0, 1, 2) ) ) ) ;

ALTER TABLE tasker_data.rt_task_status OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_task_status IS 'Reference table. Status values for tasks.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.id IS 'Unique ID for a status' ;

COMMENT ON COLUMN tasker_data.rt_task_status.name IS 'The name for a status.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.description IS 'The description of the status.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.open_status IS 'Indicates whether or not the status is open (0), closed(2), neither open or closed (1).' ;

COMMENT ON COLUMN tasker_data.rt_task_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE tasker_data.rt_task_status FROM public ;

INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (0, 'Open') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (0, 'Open - Review for closure') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (1, 'Deferred') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (1, 'Draft') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (1, 'Draft - Review for opening') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (1, 'On Hold') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (1, 'Pending') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Cancelled') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Can not fix') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Cannot implement') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Can not reproduce') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Finished') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - No longer an issue') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - No longer needed') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Other') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Out of scope') ;
INSERT INTO tasker_data.rt_task_status (open_status, name) VALUES (2, 'Closed - Will not fix') ;
