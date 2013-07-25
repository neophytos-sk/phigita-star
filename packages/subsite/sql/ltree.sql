create or replace function ltree2url (ltree)
returns text as '
declare
	p_tree_sk	alias for $1;
begin

	if p_tree_sk = '''' then
		return ''/'';
	else 
		return ''/'' || translate(textin(ltree_out(p_tree_sk)), ''.'', ''/'') || ''/'';
	end if;

end;' language 'plpgsql';

create or replace function ltree2url (text)
returns text as '
declare
	p_tree_sk	alias for $1;
begin

	if p_tree_sk = '''' then
		return ''/'';
	else 
		return ''/'' || translate(p_tree_sk, ''.'', ''/'') || ''/'';
	end if;

end;' language 'plpgsql';
