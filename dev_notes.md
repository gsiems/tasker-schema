## Dev Notes

### Naming conventions

 * Table name prefixes
   * dt_ : signifies a data table for containing user supplied data.
   * ht_ : signifies a table used for tracking historicaldata.
   * qt_ : signifies a table used for implementing/tracking a work queue.
   * rt_ : signifies a reference table that may be edited by the application administrator.
   * st_ : signifies a system table that is not to be edited.

 * View name prefixes
   * dv_ : signifies a view of the dt_-named data table for containing user supplied data.
   * hv_ : signifies a view of the ht_-named table.
   * qv_ : signifies a view of the qt_-named table.
   * rv_ : signifies a view of the rt_-named reference table that may be edited by the application administrator.
   * sv_ : signifies a view of the st_-named system table that is not to be edited.

 * No mixed-case, or forced case, identifiers are allowed. In fact, no identifiers that require quoting are allowed.

### Supported DBMS engines

The (initial at least) database supported is PostgreSQL.

It should be possible to also implement the datamodel in SQLite (and
possibly other DBMS engines). This would discourage using datatypes
that are not well supported by other DBMS engines.

### (Other) Considerations

#### Embedded Wiki?

 * Available for all tasks or just for activities?

#### Specialized tables for different task categories vs. EAV?

 * Hybrid of both?
 * For EAV, define allowed values per attribute?

#### Templates for different task categories/types?

 * Define default values for attributes?
 * Define allowed values for (some) attributes?
 * Define allowed attributes at the template level?

#### Where to put the majority of business logic?

 * **In database**
   * Use views or database functions for querying the data
   * Use database procedures for updating the data
   * Maybe use views with triggers for maintaining reference data

   * **Pros**
     * More consistent control of how data gets into the database
     * Potentially easier to support multiple clients (web, CLI, etc.)
     * Potentially less coding when creating clients (less need to repeat business logic (when creating multiple clients))
     * Provides a degree of technical documentation on how things are intended to work

   * **Cons**
     * Creates more lock-in to the specific DBMS engine
     * Not all DBMS engines support procedural functions/procedures in the database
     * May be harder to debug/troubleshoot issues

 * **Elsewhere**

   * **Pros**
     * It is the more common approach
     * More framework/ORM friendly
     * Easier to support multiple database backends

   * **Cons**
     * Creates more lock-in to whatever platform is used for creating the client(s)
     * Creating multiple clients may require repeating logic
     * Multiple clients may result in less consistent data
