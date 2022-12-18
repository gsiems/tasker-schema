SET search_path = tasker, pg_catalog ;

CREATE OR REPLACE FUNCTION user_token__request (
    a_username varchar,
    a_idle_timeout integer )
RETURNS varchar
SECURITY DEFINER
-- Set a secure search_path
SET search_path = tasker, pg_catalog, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    r record ;
    alnum CONSTANT varchar := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    token_len CONSTANT integer := 64 ;

BEGIN

    FOR r IN (
        SELECT array_to_string (
                    ARRAY (
                        SELECT substring ( alnum, trunc ( random () * length ( alnum ) )::int + 1, 1 )
                            FROM generate_series( 1, token_len )
                        ) , '' ) AS token
        ) LOOP

        IF user_token__set (
            a_username,
            r.token,
            a_idle_timeout ) THEN

            RETURN r.token ;
        END IF ;

    END LOOP ;

    RETURN null ;
END ;
$$ ;

ALTER FUNCTION user_token__request ( varchar, integer ) OWNER TO tasker_owner ;

GRANT ALL ON function user_token__request ( varchar, integer ) TO tasker_user ;

REVOKE ALL ON function user_token__request ( varchar, integer ) FROM public ;
