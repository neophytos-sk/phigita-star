create table xo.xo__timezone (
	country_code	char(2)
	,coordinates	text
	,tz		text unique not null
);

create index xo__timezone__country_code__idx on xo.xo__timezone(country_code);
copy xo.xo__timezone (country_code,coordinates,tz) from '/web/service-phigita/packages/kernel/sql/common/zone.psql_tab' with delimiter E'\t';