create sequence layer_id_seq;
create table architecture_layers (
	layer_id	integer
			primary key,
	name		varchar(100)
			unique,
	sort_key	integer
			unique
);


insert into architecture_layers (layer_id, name, sort_key)
values (nextval('layer_id_seq'), 'Infrastructure', 0);

insert into architecture_layers (layer_id, name, sort_key)
values (nextval('layer_id_seq'), 'Core', 1);

insert into architecture_layers (layer_id, name, sort_key)
values (nextval('layer_id_seq'), 'Services', 2);

insert into architecture_layers (layer_id, name, sort_key)
values (nextval('layer_id_seq'), 'Applications', 3);
