create table xo__auth_secret_tokens (
	auth_id		integer not null unique
			references users(user_id),
	auth_token	varchar(50) not null,
	creation_date	timestamp default CURRENT_TIMESTAMP not null,
	creation_ip	varchar(50) not null
);


create or replace function xo__auth_secret_token__add(integer,text,text) returns text as '
declare
	p_auth_id	alias for $1;
	p_auth_token	alias for $2;
	p_creation_ip	alias for $3;
	v_auth_token	text;
begin

	select auth_token into v_auth_token
	from xo__auth_secret_tokens
	where auth_id=p_auth_id
	limit 1;

	if v_auth_token is null then
		insert into xo__auth_secret_tokens (
		    auth_id,
		    auth_token,
		    creation_ip
		) values (
		    p_auth_id,
		    p_auth_token,
		    p_creation_ip
		);

		return p_auth_token;
	else
		update xo__auth_secret_tokens set
		    creation_date= CURRENT_TIMESTAMP,
		    creation_ip=p_creation_ip
		where auth_id=p_auth_id;
		return v_auth_token;
	end if;

	return p_auth_token;

end;' language 'plpgsql';	
