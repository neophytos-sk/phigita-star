--
-- A simple mail queue
--
-- @author <a href="mailto:eric@openforce.net">eric@openforce.net</a>
-- @version $Id: create.sql,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
--

create sequence acs_mail_lite_id_seq;

create table acs_mail_lite_queue (
    message_id                  integer
                                constraint acs_mail_lite_queue_pk
                                primary key,
    to_addr                     varchar(200),
    from_addr                   varchar(200),
    subject                     varchar(200),
    body                        text,
    extra_headers               text,
    bcc                         text
);
