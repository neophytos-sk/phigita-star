service-phigita=# create table parentof(parent text,child text);
CREATE TABLE
service-phigita=# insert into parentof(parent,child) values ('Alice','Carol');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Bob','Carol');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Carol','Dave');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Carol','George');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Dave','Mary');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Eve','Mary');
INSERT 0 1
service-phigita=# insert into parentof(parent,child) values ('Mary','Frank');
INSERT 0 1
service-phigita=# with recursive ancestor(a,d) as (select parent as a, child as d from parentof
service-phigita(# union
service-phigita(# select Ancestor.a,parentof.child as d
service-phigita(# from Ancestor,parentof
service-phigita(# where ancestor.d=parentof.parent)
service-phigita-# select a from Ancestor where d='Mary';
   a   
-------
 Dave
 Eve
 Carol
 Alice
 Bob
(5 rows)

