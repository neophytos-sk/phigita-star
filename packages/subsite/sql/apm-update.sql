create sequence apm_package_types_seq;
alter table apm_package_types add package_type_id integer default nextval('apm_package_types_seq');