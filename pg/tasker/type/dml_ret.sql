SET search_path = tasker, pg_catalog ;

CREATE TYPE dml_ret AS (
    id integer,
    numrows integer,
    err varchar ( 400 ) ) ;

ALTER TYPE dml_ret OWNER TO tasker_owner ;

COMMENT ON TYPE dml_ret IS 'Return type for DML functions.
 - ID: new ID return value,
 - numrows: the number of rows changed (in the primary table), and
 - err is any error text from the function.' ;
