--
-- bannerideas.sql
--

drop sequence idea_id_sequence;
create sequence idea_id_sequence;

-- the keyword facility gives us a way to match a banner idea
-- to page content
-- picture HTML includes a thumbnail and a full URL

drop table bannerideas;
create table bannerideas (
	idea_id		integer primary key,
	intro		varchar(4000),
	more_url	varchar(200),
	picture_html	varchar(4000),
	-- space-separated keywords
	keywords	varchar(4000),
	clickthroughs	integer default 0
);

