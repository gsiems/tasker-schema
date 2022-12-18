CREATE OR REPLACE VIEW tasker.dv_user
AS
SELECT base.id,
        base.supervisor_id,
        t002.username AS supervisor,
        durc.reporting_chain,
        --durc.user_depth,
        --durc.user_outln,
        base.edition,
        base.username,
        base.is_enabled,
        base.last_login,
        base.is_admin,
        base.can_create_activities,
        base.created_by_id,
        base.updated_by_id,
        base.created_dt,
        base.updated_dt
    FROM tasker_data.dt_user base
    LEFT JOIN tasker_data.dt_user t002
        ON ( t002.id = base.supervisor_id )
    LEFT JOIN tasker.dv_user_reporting_chain durc
        ON ( durc.user_id = base.id ) ;

ALTER VIEW tasker.dv_user OWNER TO tasker_owner ;

GRANT SELECT ON tasker.dv_user TO tasker_user ;

COMMENT ON VIEW tasker.dv_user IS 'View of: Tasker user accounts.' ;
COMMENT ON COLUMN tasker.dv_user.id IS 'Unique ID for the user account.' ;
COMMENT ON COLUMN tasker.dv_user.supervisor_id IS 'The ID of the supervisor user (if any). If the user has multiple reporting chains then choose the best one.' ;
COMMENT ON COLUMN tasker.dv_user.supervisor IS 'The username for the supervisor' ;
COMMENT ON COLUMN tasker.dv_user.reporting_chain IS 'The array of user IDs in the users reporting chain' ;
--COMMENT ON COLUMN tasker.dv_user.user_depth IS '' ;
--COMMENT ON COLUMN tasker.dv_user.user_outln IS '' ;
COMMENT ON COLUMN tasker.dv_user.edition IS 'Indicates the number of edits made to the user record. Intended for use in determining if a user has been edited between select and update.' ;
COMMENT ON COLUMN tasker.dv_user.username IS 'The username associated with the account.' ;
COMMENT ON COLUMN tasker.dv_user.is_enabled IS 'Indicates if the account is enabled (may log in) or not.' ;
COMMENT ON COLUMN tasker.dv_user.last_login IS 'The most recent time that the user has logged in.' ;
COMMENT ON COLUMN tasker.dv_user.is_admin IS 'Indicates if the account has admin privileges or not.' ;
COMMENT ON COLUMN tasker.dv_user.can_create_activities IS 'TBD' ;
COMMENT ON COLUMN tasker.dv_user.created_by_id IS 'The ID of the individual that created the row (ref dt_user).' ;
COMMENT ON COLUMN tasker.dv_user.updated_by_id IS 'The ID of the individual that most recently updated the row (ref dt_user).' ;
COMMENT ON COLUMN tasker.dv_user.created_dt IS 'The timestamp when the row was created.' ;
COMMENT ON COLUMN tasker.dv_user.updated_dt IS 'The timestamp when the row was most recently updated.' ;
