SET search_path = tasker, pg_catalog ;

CREATE TABLE rt_task_category_status (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    created_by integer,
    updated_by integer,
    category_id int2 NOT NULL,
    status_id int2 NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    CONSTRAINT rt_task_category_status_pk PRIMARY KEY ( category_id, status_id ) ) ;

ALTER TABLE rt_task_category_status
    ADD CONSTRAINT rt_task_category_status_fk01
    FOREIGN KEY ( category_id )
    REFERENCES st_task_category ( id ) ;

ALTER TABLE rt_task_category_status
    ADD CONSTRAINT rt_task_category_status_fk02
    FOREIGN KEY ( status_id )
    REFERENCES rt_task_status ( id ) ;

ALTER TABLE rt_task_category_status OWNER TO tasker_owner ;

COMMENT ON TABLE rt_task_category_status IS 'Reference table. Map task status values to task categories.' ;

COMMENT ON COLUMN rt_task_category_status.category_id IS 'The category of task that the status is for.' ;

COMMENT ON COLUMN rt_task_category_status.status_id IS 'The status.' ;

COMMENT ON COLUMN rt_task_category_status.is_enabled IS 'Indicates whether or not the status is available for use.' ;

COMMENT ON COLUMN rt_task_category_status.created_by IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_category_status.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN rt_task_category_status.updated_by IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN rt_task_category_status.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE rt_task_category_status FROM public ;


-- "Regular" tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 1 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Cannot implement',
            'Closed - Finished',
            'Closed - No longer needed',
            'Closed - Other',
            'Draft',
            'Draft - Review for opening',
            'On Hold',
            'Deferred',
            'Open',
            'Open - Review for closure'
        ) ;

-- Requirement tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 2 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Cannot implement',
            'Closed - Finished',
            'Closed - No longer needed',
            'Closed - Out of scope',
            'Closed - Other',
            'Draft',
            'Draft - Review for opening',
            'On Hold',
            'Deferred',
            'Open',
            'Open - Review for closure'
        ) ;

-- Issue tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 3 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Can not fix',
            'Closed - Can not reproduce',
            'Closed - Finished',
            'Closed - No longer an issue',
            'Closed - Out of scope',
            'Closed - Will not fix',
            'Closed - Other',
            'Draft',
            'Draft - Review for opening',
            'On Hold',
            'Deferred',
            'Open',
            'Open - Review for closure'
        ) ;

-- Meeting tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 4 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Finished',
            'Closed - Cancelled',
            'Pending',
            'On Hold',
            'Deferred',
            'Open'
        ) ;

-- Activity tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 5 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Finished',
            'Closed - No longer needed',
            'Closed - Other',
            'Pending',
            'On Hold',
            'Deferred',
            'Open',
            'Open - Review for closure'
        ) ;

-- PIP tasks
INSERT INTO rt_task_category_status (
        category_id,
        status_id
    )
    SELECT 6 AS category_id,
            id AS status_id
        FROM rt_task_status
        WHERE name IN (
            'Closed - Finished',
            'Closed - Cancelled',
            'Pending',
            'On Hold',
            'Deferred',
            'Open',
            'Open - Review for closure'
        ) ;
