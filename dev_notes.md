## Dev Notes

### Naming conventions

 * Table name prefixes
   * dt_ : signifies a data table for containing user supplied data.
   * rt_ : signifies a reference table that may be edited by the application administrator.
   * st_ : signifies a system table that is not to be edited.

 * View name prefixes
   * dv_ : signifies a view of the dt_-named data table for containing user supplied data.
   * rv_ : signifies a view of the rt_-named reference table that may be edited by the application administrator.
   * sv_ : signifies a view of the st_-named system table that is not to be edited.

 * No mixed-case, or forced case, identifiers are allowed. In fact, no identifiers that require quoting are allowed.

### Supported DBMS engines

The (initial at least) database supported is PostgreSQL.

It should be possible to also implement the datamodel in SQLite (and
possibly other DBMS engines).

### Considerations

Ideally, it would be nice to:

 * Use views and possibly database functions for querying the data
 * Use database procedures for updating the data
 * Maybe use views with triggers for maintaining reference data

Using stored functions/procedures in the database to control how data
gets into the database would allow multiple front-ends without having
to repeat as much business logic for each front end. However this would
also impose a practical limit on the DBMS engines that this could be
implemented.

Embedded Wiki?

Templates for different task categories/types?

Specialized tables for different task categories vs. EAV? Hybrid of both?
