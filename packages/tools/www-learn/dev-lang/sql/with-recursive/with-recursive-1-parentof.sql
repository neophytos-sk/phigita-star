service-phgt-0=# create table parentof(parent text,child text);
CREATE TABLE
service-phgt-0=# insert into parentof(parent,child) values ('Alice','Carol');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Bob','Carol');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Carol','Dave');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Carol','George');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Dave','Mary');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Eve','Mary');
INSERT 0 1
service-phgt-0=# insert into parentof(parent,child) values ('Mary','Frank');
INSERT 0 1
service-phgt-0=# with recursive ancestor(a,d) as (select parent as a, child as d from parentof
service-phgt-0(# union
service-phgt-0(# select Ancestor.a,parentof.child as d
service-phgt-0(# from Ancestor,parentof
service-phgt-0(# where ancestor.d=parentof.parent)
service-phgt-0-# select a from Ancestor where d='Mary';
   a   
-------
 Dave
 Eve
 Carol
 Alice
 Bob
(5 rows)

