set search_path = tasker, pg_catalog ;

CREATE TABLE st_ranking (
    id integer NOT NULL,
    name character varying ( 60 ) NOT NULL,
    CONSTRAINT st_ranking_pk PRIMARY KEY ( id ),
    CONSTRAINT st_ranking_ix1 UNIQUE ( name ) ) ;

ALTER TABLE st_ranking OWNER TO tasker_owner ;

COMMENT ON TABLE st_ranking IS 'Reference table. Ranking values for attributes such as priority, urgency, reversibility, etc.' ;

COMMENT ON column st_ranking.id IS 'Unique ID/value for the ranking.' ;

COMMENT ON column st_ranking.name IS 'Display name for the ranking.' ;

REVOKE ALL ON table st_ranking FROM public ;

INSERT INTO st_ranking (id, name) VALUES (1, 'None/Not') ;
INSERT INTO st_ranking (id, name) VALUES (2, 'Very Low') ;
INSERT INTO st_ranking (id, name) VALUES (3, 'Low') ;
INSERT INTO st_ranking (id, name) VALUES (4, 'Medium Low') ;
INSERT INTO st_ranking (id, name) VALUES (5, 'Medium') ;
INSERT INTO st_ranking (id, name) VALUES (6, 'Medium High') ;
INSERT INTO st_ranking (id, name) VALUES (7, 'High') ;
INSERT INTO st_ranking (id, name) VALUES (8, 'Very High') ;
