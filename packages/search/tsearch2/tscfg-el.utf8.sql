begin;
-- configuration
--update pg_ts_cfg set locale = 'QQ' where ts_name = 'default_english';
delete from pg_ts_cfg where ts_name = '[default_text_search_config]';
insert into pg_ts_cfg values('[default_text_search_config]','default','el_GR.utf8');

-- dictionaries

DELETE FROM pg_ts_dict WHERE dict_name = 'el_GR_ispell';
INSERT INTO pg_ts_dict
               (SELECT 'el_GR_ispell', dict_init,
                       'DictFile="/var/lib/naviserver/service-phgt-0/packages/search/tsearch2/dict/greek/el_GR.utf8.dict",'
                       'AffFile="/var/lib/naviserver/service-phgt-0/packages/search/tsearch2/dict/greek/el_GR.utf8.aff",'
		       'StopFile="/var/lib/naviserver/service-phgt-0/packages/search/tsearch2/dict/greek/el_GR.utf8.stop"'
			,dict_lexize
                FROM pg_ts_dict
                WHERE dict_name = 'ispell_template');

DELETE FROM pg_ts_dict WHERE dict_name = 'el_GR_simple';
INSERT INTO pg_ts_dict (dict_name,dict_init,dict_lexize)
               (SELECT 'el_GR_simple', dict_init,dict_lexize
                FROM pg_ts_dict
                WHERE dict_name = 'simple');


update pg_ts_dict set dict_initoption='/var/lib/naviserver/service-phgt-0/packages/search/tsearch2/dict/greek/el_GR.utf8.stop' where dict_name='el_GR_simple';

-- tokens to index
delete from pg_ts_cfgmap where ts_name = '[default_text_search_config]';
insert into pg_ts_cfgmap values('[default_text_search_config]','nlhword','{el_GR_ispell,el_GR_simple}');
insert into pg_ts_cfgmap values('[default_text_search_config]','nlword','{el_GR_ispell,el_GR_simple}');
insert into pg_ts_cfgmap values('[default_text_search_config]','nlpart_hword','{el_GR_ispell,el_GR_simple}');
end;
COPY pg_ts_cfgmap (ts_name, tok_alias, dict_name) FROM stdin;
[default_text_search_config]	lword	{en_stem}
[default_text_search_config]	word	{simple}
[default_text_search_config]	email	{simple}
[default_text_search_config]	url	{simple}
[default_text_search_config]	host	{simple}
[default_text_search_config]	sfloat	{simple}
[default_text_search_config]	version	{simple}
[default_text_search_config]	part_hword	{simple}
[default_text_search_config]	lpart_hword	{en_stem}
[default_text_search_config]	hword	{simple}
[default_text_search_config]	lhword	{en_stem}
[default_text_search_config]	uri	{simple}
[default_text_search_config]	file	{simple}
[default_text_search_config]	float	{simple}
[default_text_search_config]	int	{simple}
[default_text_search_config]	uint	{simple}
\.


