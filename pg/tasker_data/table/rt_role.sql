CREATE TABLE tasker_data.rt_role (
    created_dt timestamp with time zone DEFAULT ( now () AT TIME ZONE 'UTC' ),
    updated_dt timestamp with time zone,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    created_by_id integer,
    updated_by_id integer,
    is_enabled boolean DEFAULT true NOT NULL,
    name character varying ( 60 ) NOT NULL,
    description character varying ( 200 ),
    CONSTRAINT rt_role_pk PRIMARY KEY ( id ),
    CONSTRAINT dt_task_role_nk UNIQUE ( name ) ) ;

ALTER TABLE tasker_data.rt_role OWNER TO tasker_owner ;

COMMENT ON TABLE tasker_data.rt_role IS 'Reference table. Roles for users.' ;

COMMENT ON COLUMN tasker_data.rt_role.id IS 'Unique ID for a role' ;

COMMENT ON COLUMN tasker_data.rt_role.name IS 'The name of a role.' ;

COMMENT ON COLUMN tasker_data.rt_role.description IS 'The description of the role.' ;

COMMENT ON COLUMN tasker_data.rt_role.is_enabled IS 'Indicates whether or not the role is available for use.' ;

COMMENT ON COLUMN tasker_data.rt_role.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_role.created_dt IS 'The timestamp when the row was created.' ;

COMMENT ON COLUMN tasker_data.rt_role.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;

COMMENT ON COLUMN tasker_data.rt_role.updated_dt IS 'The timestamp when the row was most recently updated.' ;

REVOKE ALL ON TABLE tasker_data.rt_role FROM public ;

INSERT INTO tasker_data.rt_role (name, description) VALUES ('Default', 'The default role') ;
