create function inline_0 ()
returns integer as '
declare
        dummy   integer;
begin
  PERFORM acs_object_type__create_type (
    ''site_node'',
    ''Site Node'',
    ''Site Nodes'',
    ''acs_object'',
    ''site_nodes'',
    ''node_id'',
    ''site_node'',
    ''f'',
    null,
    null
    );

  return 0;
end;' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();


-- show errors

-- This table allows urls to be mapped to a node_ids.

create table site_nodes (
        node_id         integer constraint site_nodes_node_id_fk
                        references acs_objects (object_id)
                        constraint site_nodes_node_id_pk
                        primary key,
        parent_id       integer constraint site_nodes_parent_id_fk
                        references site_nodes (node_id),
        name            varchar(100)
                        constraint site_nodes_name_ck
                        check (name not like '%/%'),
        constraint site_nodes_un
        unique (parent_id, name),
        -- Is it legal to create a child node?
        directory_p     boolean not null,
        -- Should urls that are logical children of this node be
        -- mapped to this node?
        pattern_p       boolean default 'f' not null,
        object_id       integer constraint site_nodes_object_id_fk
                        references acs_objects (object_id),

	pageroot	varchar(100) default 'www' not null,
        tree_sk		ltree default ''
);

create index site_nodes_object_id_idx on site_nodes (object_id);
create index site_nodes_parent_id_idx on site_nodes(parent_id,object_id,node_id);
create index site_nodes_tree_skey_idx on site_nodes using gist (tree_sk);

create or replace function site_node__new (integer,integer,varchar,integer,boolean,boolean,integer,varchar)
returns integer as '
declare
  new__node_id                alias for $1;  -- default null  
  new__parent_id              alias for $2;  -- default null    
  new__name                   alias for $3;  
  new__object_id              alias for $4;   -- default null   
  new__directory_p            alias for $5;  
  new__pattern_p              alias for $6;   -- default ''f''
  new__creation_user          alias for $7;   -- default null   
  new__creation_ip            alias for $8;   -- default null   
  v_node_id                   site_nodes.node_id%TYPE;
  v_directory_p               site_nodes.directory_p%TYPE;
  v_tree_sk		      site_nodes.tree_sk%TYPE;
begin
	v_tree_sk := new__name;

    if new__parent_id is not null then
      select directory_p into v_directory_p
      from site_nodes
      where node_id = new__parent_id;

	select tree_sk into v_tree_sk
	from site_nodes
	where node_id = new__parent_id;

	v_tree_sk := v_tree_sk || new__name;

      if v_directory_p = ''f'' then
        raise EXCEPTION ''-20000: Node % is not a directory'', new__parent_id;
      end if;

    end if;

    v_node_id := acs_object__new (
      new__node_id,
      ''site_node'',
      now(),
      new__creation_user,
      new__creation_ip,
      null
    );

    insert into site_nodes
     (node_id, parent_id, name, object_id, directory_p, pattern_p,tree_sk)
    values
     (v_node_id, new__parent_id, new__name, new__object_id,
      new__directory_p, new__pattern_p,v_tree_sk);

     return v_node_id;
   
end;' language 'plpgsql';


-- procedure delete
create function site_node__delete (integer)
returns integer as '
declare
  delete__node_id                alias for $1;  
begin
    delete from site_nodes
    where node_id = delete__node_id;

    PERFORM acs_object__delete(delete__node_id);

    return 0; 
end;' language 'plpgsql';


-- function find_pattern
create function site_node__find_pattern (integer)
returns integer as '
declare
  find_pattern__node_id         alias for $1;  
  v_pattern_p                   site_nodes.pattern_p%TYPE;
  v_parent_id                   site_nodes.node_id%TYPE;
begin
    if find_pattern__node_id is null then
--      raise no_data_found;
        raise exception ''NO DATA FOUND'';
    end if;

    select pattern_p, parent_id into v_pattern_p, v_parent_id
    from site_nodes
    where node_id = find_pattern__node_id;

    if v_pattern_p = ''t'' then
      return find_pattern__node_id;
    else
      return site_node__find_pattern(v_parent_id);
    end if;
   
end;' language 'plpgsql';


-- function node_id
create function site_node__node_id (varchar,integer)
returns integer as '
declare
  node_id__url           alias for $1;  
  node_id__parent_id     alias for $2;  -- default null  
  v_pos                  integer;       
  v_first                site_nodes.name%TYPE;
  v_rest                 text; 
  v_node_id              integer;       
  v_pattern_p            site_nodes.pattern_p%TYPE;
  v_url                  text; 
  v_directory_p          site_nodes.directory_p%TYPE;
  v_trailing_slash_p     boolean;       
begin
    v_url := node_id__url;

    if substr(v_url, length(v_url), 1) = ''/'' then
      -- It ends with a / so it must be a directory.
      v_trailing_slash_p := ''t'';
      v_url := substr(v_url, 1, length(v_url) - 1);
    end if;

    v_pos := 1;

    while v_pos <= length(v_url) and substr(v_url, v_pos, 1) <> ''/'' loop
      v_pos := v_pos + 1;
    end loop;

    if v_pos = length(v_url) then
      v_first := v_url;
      v_rest := null;
    else
      v_first := substr(v_url, 1, v_pos - 1);
      v_rest := substr(v_url, v_pos + 1);
    end if;

    -- begin
      -- Is there a better way to do these freaking null compares?
      select node_id, directory_p into v_node_id, v_directory_p
      from site_nodes
      where coalesce(parent_id, 3.14) = coalesce(node_id__parent_id, 3.14)
      and coalesce(name, chr(10)) = coalesce(v_first, chr(10));
    if NOT FOUND then 
        return site_node__find_pattern(node_id__parent_id);
    end if;

    if v_rest is null then
      if v_trailing_slash_p = ''t'' and v_directory_p = ''f'' then
        return site_node__find_pattern(node_id__parent_id);
      else
        return v_node_id;
      end if;
    else
      return site_node__node_id(v_rest, v_node_id);
    end if;


end;' language 'plpgsql';


-- function url
create function site_node__url (integer)
returns varchar as '
declare
  url__node_id           alias for $1;  
  v_parent_id            site_nodes.node_id%TYPE;
  v_name                 site_nodes.name%TYPE;
  v_directory_p          site_nodes.directory_p%TYPE;
begin
    if url__node_id is null then
      return '''';
    end if;

    select parent_id, name, directory_p into
           v_parent_id, v_name, v_directory_p
    from site_nodes
    where node_id = url__node_id;

    if v_directory_p = ''t'' then
      return site_node__url(v_parent_id) || v_name || ''/'';
    else
      return site_node__url(v_parent_id) || v_name;
    end if;
   
end;' language 'plpgsql';



-- show errors

\i site-nodes/subsite-callbacks-create.sql
