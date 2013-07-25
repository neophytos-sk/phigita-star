create or replace function xo__ensure_schema (text) returns integer as '
declare
    p__schema		alias for $1;
begin
    execute ''create schema '' || p__schema;
    return 1;
    exception when duplicate_schema then
    return 0;
end;' language 'plpgsql';



create or replace function xo__ensure_class (text) returns integer as '
declare
    p__class_ddl	alias for $1;
begin
    execute p__class_ddl;
    return 1;
    exception when duplicate_table then
    return 0;
end;' language 'plpgsql';



create or replace function xo__ensure_sequence (text,text) returns integer as '
declare
    p__schema		alias for $1;
    p__sequence		alias for $2;
begin
    execute ''create sequence '' || p__sequence;
    return 1;
    exception 
      when undefined_schema then
	perform xo__ensure_schema(p__schema);
        perform xo__ensure_sequence(p__schema,p__sequence);
        return 0;
      when duplicate_table then
        return 0;
end;' language 'plpgsql';



create or replace function xo__nextval (text,text) returns integer as '
declare
    p__schema		alias for $1;
    p__sequence		alias for $2;
begin
    return nextval(p__sequence);
    exception 
	when undefined_schema then
	    perform xo__ensure_schema(p__schema);
            perform xo__ensure_sequence(p__schema,p__sequence);
	    return nextval(p__sequence);	
	when undefined_table then
	    perform xo__ensure_sequence(p__schema,p__sequence);
	    return nextval(p__sequence);
end;' language 'plpgsql';


create or replace function xo__nextval (text) returns integer as '
declare
    p__sequence         alias for $1;
begin
    execute ''create sequence '' || p__sequence;
    return nextval(p__sequence);
    return 1;
    exception when duplicate_table then
    return nextval(p__sequence);
end;' language 'plpgsql';

create or replace function xo__catch (text) returns integer as '
declare
    p__script         alias for $1;
begin
    execute p__script;
    return 1;
    exception when undefined_table then
    return 0;
end;' language 'plpgsql';


create or replace function xo__insert_dml (text,text) returns integer as '
declare
    p__insert_dml	alias for $1;
    p__jic_sql		alias for $2;
begin
    execute p__insert_dml;
    return 1;
    exception when unique_violation then
    execute p__jic_sql;
    return 0;
end;' language 'plpgsql';


   -- Function form of || operator
   CREATE OR REPLACE FUNCTION xo__catenate(text,text) RETURNS text AS '
      SELECT COALESCE($1 || $2,$1,$2,NULL)
   ' LANGUAGE SQL;
	
   -- How to concatenate strings in an aggregate
   CREATE AGGREGATE xo__concatenate_aggregate (
      sfunc = xo__catenate,
      basetype = text,
      stype = text,
      initcond = ''
   );


   -- Function form of || operator
   CREATE OR REPLACE FUNCTION xo__catenate_tsvector(tsvector,tsvector) RETURNS tsvector AS '
      SELECT COALESCE($1 || $2,$1,$2,NULL)
   ' LANGUAGE SQL;
	
   -- How to concatenate strings in an aggregate
   CREATE AGGREGATE xo__concatenate_tsvector_aggregate (
      sfunc = xo__catenate_tsvector,
      basetype = tsvector,
      stype = tsvector,
      initcond = ''
   );

