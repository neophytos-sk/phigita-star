-- Creates support tables and useful views for the calendar system
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 30, 2000
-- @cvs-id $Id: cal-table-create.sql,v 1.5 2001/10/15 18:46:59 donb Exp $
--
-- @ported by Charles Mok (mok_cl@eelab.usyd.edu.au)

-------------------------------------------------------
-- Calendar Support Tables
-------------------------------------------------------

  -- Table cal_party_prefs stores customization information
  -- for each calendar. These data are unique to each party. 
  -- This means that each party using the same calendar can 
  -- have a different look to it. 
create table cal_party_prefs (
          -- refers to a particular calendar Id
        calendar_id             integer
                                constraint cal_pty_prefs_cal_id_fk
                                references calendars
                                on delete cascade,       
           -- Party Id
        party_id                integer
                                constraint cal_pty_prefs_party_id_fk  
                                references parties
                                on delete cascade,
          -- default_view stores whether the user wants 
          -- list, month, day, week, or year as his/her default view.
        default_view            varchar(10)
                                default 'day'
                                constraint cal_pty_prefs_default_view_ck
                                check (default_view in (
					'list', 
                                        'day',  
                                        'week', 
                                        'month', 
                                        'year'
                                        )
                                ),                              
          -- the default number of minutes for each appointment
        default_duration        integer
                                default 60
                                constraint cal_pty_prefs_default_duration
                                check (default_duration > 0),
          -- the default starting time in daily view in military time 00 - 23
        daily_start             --number(2)
				numeric(2,0) 
                                default 07
                                constraint cal_pty_prefs_daily_start
                                check (daily_start < 24 and daily_start > -1),
          -- the default ending time in daily view in military time 00 -23
        daily_end               --number(2)
				numeric(2,0)
                                default 18
                                constraint cal_pty_prefs_daily_end 
                                check (daily_end < 24 and daily_end > 0),
          -- which time zone does the user belong to
        time_zone               integer 
                                constraint cal_pty_prefs_time_zone_fk
                                references timezones
                                on delete cascade
				check (time_zone > 0),
          -- which day to start the week, monday or sunday
        first_day_of_week       varchar(9)
                                default 'Sunday'
                                constraint cal_pty_prefs_1st_day_ck
                                check (first_day_of_week in (
				        'Sunday', 
                                        'Monday', 
                                        'Tuesday', 
                                        'Wednesday', 
                                        'Thursday', 
                                        'Friday', 
                                        'Saturday'
                                        )
                                ),
          -- unique constraint between calendar_id and party_id
          -- this ensures that each party has only one set of 
          -- perferences per calendar
        constraint cal_party_prefs_un unique(calendar_id, party_id)
);


comment on table cal_party_prefs is '
        Table cal_user_prefs would stores custom information
        about each indivdual user. This would include time zone
        which is the first day of the week, monday or sunday, 
        and the likes. 
';

comment on column cal_party_prefs.party_id is '
        Maps to a party
';

comment on column cal_party_prefs.default_view is '
        default_view stores whether the user wants
        list, month, day, week, or year as his/her default view. 
';

comment on column cal_party_prefs.default_duration is '
        the default number of minutes for each appointment
';


comment on column cal_party_prefs.daily_start is '
        the default start time in daily view in military time 00 - 23
        default to 07 or 7 am
';

comment on column cal_party_prefs.daily_end is '
        the default end time in daily view in military time 00 - 23
        default to 18 or 6 pm
';

--comment on column cal_party_prefs.time_zone is '
--        The time zone that the user is in. This is useful in sending out 
--        reminders and other applications
--';

comment on column cal_party_prefs.first_day_of_week is '
        Which day of the week will be displayed first in month and week view    
';
 


















