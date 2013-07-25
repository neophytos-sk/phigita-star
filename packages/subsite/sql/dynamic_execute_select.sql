create or replace function my_dynamic_query (text,text,text,text) returns record as '
declare
	p__select             	alias for $1;
	p__schema		alias for $2;
	p__table		alias for $3;
	p__constraints 		alias for $4;
	v__result		record;

begin

	FOR v__result IN EXECUTE ''SELECT ''
	        || quote_literal(p__select)
		|| '' FROM ''
		|| quote_ident(p__schema)
		|| ''.''
		|| quote_ident(p__table)
		|| '' WHERE ''
		|| quote_ident(p__constraints) 
		|| '' LIMIT 1''
	LOOP

	i := i+1;

	END LOOP;

	return v__result;

end' language 'plpgsql';

create or replace function my_dynamic_query_ret_text (text,text,text,text) returns text as '
declare
	p__select             	alias for $1;
	p__schema		alias for $2;
	p__table		alias for $3;
	p__constraints 		alias for $4;
	v__result		record;
begin

	FOR v__result IN EXECUTE ''SELECT ''
	        || p__select
		|| '' AS value FROM ''
		|| quote_ident(p__schema)
		|| ''.''
		|| quote_ident(p__table)
		|| '' WHERE ''
		|| quote_ident(p__constraints) 
		|| '' LIMIT 1''
	LOOP


	END LOOP;

	return v__result.value;

end' language 'plpgsql';

create or replace function my_dynamic_query_ret_int (text,text,text,text) returns integer as '
declare
	p__select             	alias for $1;
	p__schema		alias for $2;
	p__table		alias for $3;
	p__constraints 		alias for $4;
	v__result		record;
begin

	FOR v__result IN EXECUTE ''SELECT ''
	        || p__select
		|| '' AS value FROM ''
		|| quote_ident(p__schema)
		|| ''.''
		|| quote_ident(p__table)
		|| '' WHERE ''
		|| quote_ident(p__constraints) 
		|| '' LIMIT 1''
	LOOP


	END LOOP;

	return v__result.value;

end' language 'plpgsql';
