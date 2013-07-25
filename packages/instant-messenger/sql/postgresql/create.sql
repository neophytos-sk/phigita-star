/* Create the Jabber database */

/* $Id: sample_database.pg.sql,v 1.3 2002/10/20 16:52:05 bobeal Exp $ */

/* User information table - authentication information and profile */
CREATE TABLE users0k (
  username VARCHAR(64) NOT NULL PRIMARY KEY,
  hash     VARCHAR(41) NOT NULL,
  token    VARCHAR(10) NOT NULL,
  sequence VARCHAR(3)  NOT NULL
);

CREATE TABLE last (
  username VARCHAR(64) NOT NULL PRIMARY KEY,
  seconds  VARCHAR(32) NOT NULL,
  state	   VARCHAR(32)
);

/* User resource mappings */
CREATE TABLE userres (
  username VARCHAR(64) NOT NULL,
  resource VARCHAR(32) NOT NULL
);
CREATE UNIQUE INDEX PK_userres ON userres (username, resource);

/* Roster listing */
CREATE TABLE rosterusers (
  username VARCHAR(64) NOT NULL,
  jid VARCHAR(64) NOT NULL,
  nick VARCHAR(255),
  subscription CHAR(1) NOT NULL,  /* 'N', 'T', 'F', or 'B' */
  ask CHAR(1) NOT NULL,           /* '-', 'S', or 'U' */
  server CHAR(1) NOT NULL,         /* 'Y' or 'N' */
  subscribe VARCHAR(255),
  type VARCHAR(64)
);
CREATE INDEX I_rosteru_username ON rosterusers (username);

CREATE TABLE rostergroups
(
  username VARCHAR(64) NOT NULL,
  jid VARCHAR(64) NOT NULL,
  grp VARCHAR(64) NOT NULL
);
CREATE UNIQUE INDEX PK_rosterg_user_jid ON rostergroups (username, jid);

/* Spooled offline messages */
CREATE TABLE spool (
  username VARCHAR(64) NOT NULL,
  receiver VARCHAR(255) NOT NULL,
  sender VARCHAR(255) NOT NULL,                 
  id VARCHAR(255),
  date TIMESTAMP,
  priority INT,
  type VARCHAR(32),
  thread VARCHAR(255),
  subject VARCHAR(255),
  message TEXT,
  extension TEXT
);
CREATE INDEX I_despool on spool (username, date);

CREATE TABLE filters (
  username     VARCHAR(64),
  unavailable  VARCHAR(1),
  sender       VARCHAR(255),
  resource     VARCHAR(32),
  subject      VARCHAR(255),
  body         TEXT,
  show_state   VARCHAR(8),
  type         VARCHAR(8),
  offline      VARCHAR(1),
  forward      VARCHAR(32),
  reply        TEXT,
  continue     VARCHAR(1),
  settype      VARCHAR(8)
);

CREATE TABLE vcard (
  username   VARCHAR(64) PRIMARY KEY,
  full_name  VARCHAR(65),
  first_name VARCHAR(32),
  last_name  VARCHAR(32),
  nick_name  VARCHAR(32),
  url        VARCHAR(255),
  address1   VARCHAR(255),
  address2   VARCHAR(255),
  locality   VARCHAR(32),
  region     VARCHAR(32),
  pcode      VARCHAR(32),
  country    VARCHAR(32),
  telephone  VARCHAR(32),
  email      VARCHAR(127),
  orgname    VARCHAR(32),
  orgunit    VARCHAR(32),
  title      VARCHAR(32),
  role       VARCHAR(32),
  b_day      DATE,
  descr      TEXT
);

CREATE TABLE yahoo (
  username   VARCHAR(128) PRIMARY KEY,
  id         VARCHAR(100) NOT NULL,
  pass       VARCHAR(32) NOT NULL
);

CREATE TABLE icq (
  username   VARCHAR(128) PRIMARY KEY,
  id         VARCHAR(100) NOT NULL,
  pass       VARCHAR(32) NOT NULL
);

CREATE TABLE aim (
  username   VARCHAR(128) PRIMARY KEY,
  id         VARCHAR(100) NOT NULL,
  pass       VARCHAR(32) NOT NULL
);

/* XXX : add tables for aim and icq roster

alter table users0k add constraint users0k_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table last add constraint last_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table userres add constraint userres_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table rosterusers add constraint rosterusers_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table rostergroups add constraint rostergroups_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table spool add constraint spool_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table filters add constraint filters_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table vcard add constraint vcard_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table yahoo add constraint yahoo_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table icq add constraint icq_user
    foreign key(username) references users(screen_name) on delete cascade;

alter table aim add constraint aim_user
    foreign key(username) references users(screen_name) on delete cascade;

 */
