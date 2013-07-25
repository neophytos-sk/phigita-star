
create table wiki_pages (
       page_id integer not null primary key,
       page_url varchar(200) not null,
       view_by_public boolean default true,
       created_by integer references users(user_id) not null,
       creation_date timestamp not null,
       creation_ip varchar(50) not null,      
       last_modified_by integer references users(user_id) not null,
       last_modified_date timestamp not null,
       last_modified_ip varchar(50) not null,      
       page_contents text not null,
       dirty_p boolean not null default false
);      

create table wiki_revisions (
       page_id integer references wiki_pages(page_id),
       revision_id integer not null,
       summary varchar(100),
       minor_edit_p boolean default true,
       made_on timestamp not null,
       made_by integer references users(user_id) not null,
       made_by_ip varchar(50) not null,             
       revision text not null,
       primary key (page_id,revision_id)
);

create index wiki_page_url_idx on wiki_pages(page_url);
create sequence wiki_page_id_seq start  1;
create sequence wiki_revision_id_seq start 1;
