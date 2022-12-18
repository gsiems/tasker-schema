CREATE TABLE tasker_data.rt_task_category_status (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    category_id int2 NOT NULL,
    status_id int2 NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_by_id integer,
    updated_by_id integer,
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    CONSTRAINT rt_task_category_status_pk PRIMARY KEY ( id ),
    CONSTRAINT rt_task_category_status_nk UNIQUE ( category_id, status_id ) ) ;

ALTER TABLE tasker_data.rt_task_category_status
    ADD CONSTRAINT rt_task_category_status_fk01
    FOREIGN KEY ( category_id )
    REFERENCES tasker_data.st_task_category ( id ) ;

ALTER TABLE tasker_data.rt_task_category_status
    ADD CONSTRAINT rt_task_category_status_fk02
    FOREIGN KEY ( status_id )
    REFERENCES tasker_data.rt_task_status ( id ) ;

ALTER TABLE tasker_data.rt_task_category_status OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_task_category_status IS 'Reference table. Map task status values to task categories.' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.category_id IS 'The category of task that the status is for.' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.status_id IS 'The status.' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_task_category_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

-- "Regular" tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'Task'
            AND rts.name IN (
                'New',
                'Cannot implement',
                'Finished',
                'No longer needed',
                'Other',
                'Draft',
                'Draft - Review for opening',
                'On Hold',
                'Deferred',
                'In process',
                'Review for closure'
            ) ;

-- Requirement tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'Requirement'
            AND rts.name IN (
                'New',
                'Cannot implement',
                'Finished',
                'No longer needed',
                'Out of scope',
                'Other',
                'Draft',
                'Draft - Review for opening',
                'On Hold',
                'Deferred',
                'In process',
                'Review for closure'
            ) ;

-- Issue tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'Issue'
            AND rts.name IN (
                'New',
                'Can not fix',
                'Can not reproduce',
                'Finished',
                'No longer an issue',
                'Out of scope',
                'Will not fix',
                'Other',
                'Draft',
                'Draft - Review for opening',
                'On Hold',
                'Deferred',
                'In process',
                'Review for closure'
            ) ;

-- Meeting tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'Meeting'
            AND rts.name IN (
                'Finished',
                'Cancelled',
                'Pending',
                'On Hold',
                'Deferred',
                'In process'
            ) ;

-- Activity tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'Activity'
            AND rts.name IN (
                'Finished',
                'No longer needed',
                'Other',
                'Pending',
                'On Hold',
                'Deferred',
                'In process',
                'Review for closure'
            ) ;

-- PIP tasks
INSERT INTO tasker_data.rt_task_category_status (
        category_id,
        status_id
    )
    SELECT stc.id AS category_id,
            rts.id AS status_id
        FROM tasker_data.rt_task_status rts
        CROSS JOIN tasker_data.st_task_category stc
        WHERE stc.name = 'PIP'
            AND rts.name IN (
                'Finished',
                'Cancelled',
                'Pending',
                'On Hold',
                'Deferred',
                'In process',
                'Review for closure'
            ) ;
