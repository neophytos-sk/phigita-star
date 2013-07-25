create table users (
	user_id			integer not null
				constraint users_user_id_fk
				references persons (person_id)
				constraint users_pk primary key,
	password		char(40),
	salt			char(40),
	screen_name		varchar(100)
				constraint users_screen_name_un
				unique,
	priv_name		integer default 0 not null,
	priv_email		integer default 5 not null,
	email_verified_p	boolean default 't',
	email_bouncing_p	boolean default 'f' not null,
	no_alerts_until		timestamptz,
	last_visit		timestamptz,
	second_to_last_visit	timestamptz,
	n_sessions		integer default 1 not null,
	password_question	varchar(1000),
	password_answer		varchar(1000),
	status	               	varchar(40),
	roles			ltree[]
);

create table user_preferences (
	user_id			integer constraint user_prefs_user_id_fk
				references users (user_id)
				constraint user_preferences_pk
				primary key,
	prefer_text_only_p	boolean default 'f',
	-- an ISO 639 language code (in lowercase)
	language_preference	char(2) default 'en',
	dont_spam_me_p		boolean default 'f',
	email_type		varchar(64)
);

create function inline_1 ()
returns integer as '
begin

  insert into acs_object_type_tables
    (object_type, table_name, id_column)
    values
    (''user'', ''user_preferences'', ''user_id'');
  return 0;
end;' language 'plpgsql';

select inline_1 ();

drop function inline_1 ();


-- show errors


alter table acs_objects add
  constraint acs_objects_creation_user_fk
  foreign key (creation_user) references users(user_id);
alter table acs_objects add
  constraint acs_objects_modifying_user_fk
  foreign key (modifying_user) references users(user_id);

comment on table users is '
 The creation_date and creation_ip columns inherited from acs_objects
 indicate when and from where the user registered. How do we apply a
 constraint ("email must not be null") to the parent type?
';

comment on column users.no_alerts_until is '
 For suppressing email alerts
';

comment on column users.last_visit is '
 Set when user reappears at site
';

comment on column users.second_to_last_visit is '
 This is what most pages query against (since last_visit will only be
 a few minutes old for most pages in a session)
';

comment on column users.n_sessions is '
 How many times this user has visited
';

-- create or replace package body acs_user
-- function new
select define_function_args('user__new','user_id,object_type;user,creation_date;now(),creation_user,creation_ip,email,url,first_names,last_name,password,salt,password_question,password_answer,screen_name,email_verified_p;t,context_id');


create function acs_user__new (integer,varchar,timestamptz,integer,varchar,varchar,varchar,varchar,varchar,char,char,varchar,varchar,varchar,boolean,integer)
returns integer as '
declare
  new__user_id                  alias for $1;  -- default null  
  new__object_type              alias for $2;  -- default ''user''
  new__creation_date            alias for $3;  -- default now()
  new__creation_user            alias for $4;  -- default null
  new__creation_ip              alias for $5;  -- default null
  new__email                    alias for $6;  
  new__url                      alias for $7;  -- default null
  new__first_names              alias for $8;  
  new__last_name                alias for $9;  
  new__password                 alias for $10; 
  new__salt                     alias for $11; 
  new__password_question        alias for $12; -- default null
  new__password_answer          alias for $13; -- default null
  new__screen_name              alias for $14; -- default null
  new__email_verified_p         alias for $15; -- default ''t''
  new__context_id               alias for $16; -- default null
  v_user_id                     users.user_id%TYPE;
  person_exists			varchar;			
begin
  v_user_id := new__user_id;

  select case when count(*) = 0 then ''f'' else ''t'' end into person_exists
   from persons where person_id = v_user_id;

  if person_exists = ''f'' then

  v_user_id :=
   person__new(v_user_id, new__object_type,
               new__creation_date, new__creation_user, new__creation_ip,
               new__email, new__url, new__first_names, new__last_name, 
               new__context_id);
  else
   update acs_objects set object_type = ''user'' where object_id = v_user_id;
  end if;

  insert into users
   (user_id, password, salt, password_question, password_answer, screen_name,
    email_verified_p)
  values
   (v_user_id, new__password, new__salt, new__password_question, 
    new__password_answer, new__screen_name, new__email_verified_p);

  insert into user_preferences
    (user_id)
    values
    (v_user_id);

  return v_user_id;
  
end;' language 'plpgsql';


create function acs_user__new(varchar,varchar,varchar,char,char) 
returns integer as '
declare
        email   alias for $1;
        fname   alias for $2;
        lname   alias for $3;
        pword   alias for $4;
        salt    alias for $5;
begin
        return acs_user__new(null,
                             ''user'',
                             now(),
                             null,
                             null,                
                             email,
                             null,
                             fname,
                             lname,
                             pword,
                             salt,
                             null,
                             null,
                             null,
                             ''t'',
                             null
                             );

end;' language 'plpgsql';


-- function receives_alerts_p
create function acs_user__receives_alerts_p (integer)
returns boolean as '
declare
  receives_alerts_p__user_id                alias for $1;  
  counter                                   boolean;       
begin
  select case when count(*) = 0 then ''f'' else ''t'' end into counter
   from users
   where no_alerts_until >= now()
   and user_id = receives_alerts_p__user_id;

  return counter;
  
end;' language 'plpgsql';


-- procedure approve_email
create function acs_user__approve_email (integer)
returns integer as '
declare
  approve_email__user_id        alias for $1;  
begin
    update users
    set email_verified_p = ''t''
    where user_id = approve_email__user_id;

    return 0; 
end;' language 'plpgsql';


-- procedure unapprove_email
create function acs_user__unapprove_email (integer)
returns integer as '
declare
  unapprove_email__user_id      alias for $1;  
begin
    update users
    set email_verified_p = ''f''
    where user_id = unapprove_email__user_id;

    return 0; 
end;' language 'plpgsql';


-- procedure delete
create function acs_user__delete (integer)
returns integer as '
declare
  delete__user_id       alias for $1;  
begin
  delete from user_preferences
  where user_id = delete__user_id;

  delete from users
  where user_id = delete__user_id;

  PERFORM person__delete(delete__user_id);

  return 0; 
end;' language 'plpgsql';


\i groups/groups-create.sql
