CREATE TABLE tasker_data.rt_task_status (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    status_category_id int2 NOT NULL,
    name text NOT NULL,
    description text,
    is_default boolean NOT NULL default false,
    is_enabled boolean NOT NULL default true,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT rt_task_status_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_task_status_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.rt_task_status
    ADD CONSTRAINT rt_task_status_fk01
    FOREIGN KEY ( status_category_id )
    REFERENCES tasker_data.st_status_category ( id ) ;

ALTER TABLE tasker_data.rt_task_status OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_task_status IS 'Reference table. Statuses for tasks.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.id IS 'Unique ID for the status' ;

COMMENT ON COLUMN tasker_data.rt_task_status.status_category_id IS 'The ID of the category indicating if the status is open, closed, or not open.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.name IS 'The name of the status.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.description IS 'The description of the status.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.is_default IS 'Indicates whether or not the row is the default row.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_task_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

INSERT INTO tasker_data.rt_task_status (
        status_category_id,
        name,
        description )
    SELECT soc.id AS status_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_status_category soc
        JOIN (
            VALUES
                ( 'Not Open', 'New', '' ),
                ( 'Not Open', 'Deferred', '' ),
                ( 'Not Open', 'Draft', '' ),
                ( 'Not Open', 'Draft - Review for opening', '' ),
                ( 'Not Open', 'On Hold', '' ),
                ( 'Not Open', 'Pending', '' )
            ) AS dat ( status_category, name, description )
            ON ( dat.status_category = soc.name ) ;

UPDATE tasker_data.rt_task_status
    SET is_default = true
    WHERE name = 'New' ;

INSERT INTO tasker_data.rt_task_status (
        status_category_id,
        name,
        description )
    SELECT soc.id AS status_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_status_category soc
        JOIN (
            VALUES
                ( 'Open', 'In process', '' ),
                ( 'Open', 'In QA', '' ),
                ( 'Open', 'In testing', '' ),
                ( 'Open', 'Review for closure', '' )
            ) AS dat ( status_category, name, description )
            ON ( dat.status_category = soc.name ) ;

UPDATE tasker_data.rt_task_status
    SET is_default = true
    WHERE name = 'In process' ;

INSERT INTO tasker_data.rt_task_status (
        status_category_id,
        name,
        description )
    SELECT soc.id AS status_category_id,
            dat.name,
            dat.description
        FROM tasker_data.st_status_category soc
        JOIN (
            VALUES
                ( 'Closed', 'Canceled', '' ),
                ( 'Closed', 'Can not fix', '' ),
                ( 'Closed', 'Cannot implement', '' ),
                ( 'Closed', 'Can not reproduce', '' ),
                ( 'Closed', 'Finished', '' ),
                ( 'Closed', 'No longer an issue', '' ),
                ( 'Closed', 'No longer needed', '' ),
                ( 'Closed', 'Other', '' ),
                ( 'Closed', 'Out of scope', '' ),
                ( 'Closed', 'Will not fix', '' )
            ) AS dat ( status_category, name, description )
            ON ( dat.status_category = soc.name ) ;
