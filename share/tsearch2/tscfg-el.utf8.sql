begin;
-- configuration
--update pg_ts_cfg set locale = 'QQ' where ts_name = 'default_english';
delete from pg_ts_cfg where ts_name = 'default_greek';
insert into pg_ts_cfg values('default_greek','default','el_GR.utf8');

-- dictionaries

DELETE FROM pg_ts_dict WHERE dict_name = 'el_GR_ispell';
INSERT INTO pg_ts_dict
               (SELECT 'el_GR_ispell', dict_init,
                       'DictFile="/web/share/tsearch2/dict/greek/el_GR.utf8.dict",'
                       'AffFile="/web/share/tsearch2/dict/greek/el_GR.utf8.aff",'
		       'StopFile="/web/share/tsearch2/dict/greek/el_GR.utf8.stop"'
			,dict_lexize
                FROM pg_ts_dict
                WHERE dict_name = 'ispell_template');

DELETE FROM pg_ts_dict WHERE dict_name = 'el_GR_simple';
INSERT INTO pg_ts_dict (dict_name,dict_init,dict_lexize)
               (SELECT 'el_GR_simple', dict_init,dict_lexize
                FROM pg_ts_dict
                WHERE dict_name = 'simple');


update pg_ts_dict set dict_initoption='/web/share/tsearch2/dict/greek/el_GR.utf8.stop' where dict_name='el_GR_simple';

-- tokens to index
delete from pg_ts_cfgmap where ts_name = 'default_greek';
insert into pg_ts_cfgmap values('default_greek','nlhword','{el_GR_ispell,el_GR_simple}');
insert into pg_ts_cfgmap values('default_greek','nlword','{el_GR_ispell,el_GR_simple}');
insert into pg_ts_cfgmap values('default_greek','nlpart_hword','{el_GR_ispell,el_GR_simple}');
end;
COPY pg_ts_cfgmap (ts_name, tok_alias, dict_name) FROM stdin;
default_greek	lword	{en_stem}
default_greek	word	{simple}
default_greek	email	{simple}
default_greek	url	{simple}
default_greek	host	{simple}
default_greek	sfloat	{simple}
default_greek	version	{simple}
default_greek	part_hword	{simple}
default_greek	lpart_hword	{en_stem}
default_greek	hword	{simple}
default_greek	lhword	{en_stem}
default_greek	uri	{simple}
default_greek	file	{simple}
default_greek	float	{simple}
default_greek	int	{simple}
default_greek	uint	{simple}
\.


