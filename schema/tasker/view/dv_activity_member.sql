CREATE OR REPLACE VIEW tasker.dv_activity_member
AS
SELECT base.id,
        base.activity_id,
        t002.task_name AS activity_name,
        base.user_id,
        t003.username,
        base.role_id,
        t004.name AS role,
        base.created_by_id,
        base.updated_by_id,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.dt_activity_member base
    JOIN tasker_data.dt_task t002
        ON ( t002.id = base.activity_id )
    JOIN tasker_data.dt_user t003
        ON ( t003.id = base.user_id )
    JOIN tasker_data.st_role t004
        ON ( t004.id = base.role_id ) ;

ALTER VIEW tasker.dv_activity_member OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_activity_member TO tasker_user ;

COMMENT ON VIEW tasker.dv_activity_member IS 'View of: Team members assigned to tasks.' ;
COMMENT ON COLUMN tasker.dv_activity_member.id IS 'The unique ID for the activity-member.' ;
COMMENT ON COLUMN tasker.dv_activity_member.activity_id IS 'The activity that the user is a member of.' ;
COMMENT ON COLUMN tasker.dv_activity_member.activity_name IS 'The name of the activity that the user is a member of.' ;
COMMENT ON COLUMN tasker.dv_activity_member.user_id IS 'The user that is a member of the activity.' ;
COMMENT ON COLUMN tasker.dv_activity_member.username IS 'The username for the user' ;
COMMENT ON COLUMN tasker.dv_activity_member.role_id IS 'The role that the user has for the activity.' ;
COMMENT ON COLUMN tasker.dv_activity_member.role IS 'The name for the role' ;
COMMENT ON COLUMN tasker.dv_activity_member.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;
COMMENT ON COLUMN tasker.dv_activity_member.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;
COMMENT ON COLUMN tasker.dv_activity_member.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.dv_activity_member.updated_dt IS 'The timestamp when the row was most recently updated.' ;
