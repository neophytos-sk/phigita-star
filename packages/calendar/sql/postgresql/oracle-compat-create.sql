-- packages/acs-events/sql/postgres/oracle-compat-create.sql
--
-- Functions to ease porting from Postgres to Oracle
--
-- @author jowell@jsabino.com
-- @creation-date 2001-06-26
--
-- $Id: oracle-compat-create.sql,v 1.4 2003/05/17 09:46:57 jeffd Exp $

create function dow_to_int (
       --
       -- Convert string to day of the week
       --
       -- Note that the output of extract(dow from timestamp) and to_char(timestamp,'D')
       -- are different!  to_char is more consistent with Oracle, so we only use to_char.
       --
       -- @author jowell@jsabino.com
       --
       -- @param weekday	Day of the week string to be converted to Postgres int representation
       --
       -- @return integer corresponding to Postgres representation of day of the week (Sunday = 0)
       --       
       varchar
)
returns integer as '
declare
       dow_to_int__weekday	alias for $1;
       v_dow			integer;
begin
       -- Brute force (what can I say?).
       select (case trim(upper(dow_to_int__weekday))
	             when ''SUNDAY''    then 1
	             when ''SUN''       then 1
		     when ''MONDAY''    then 2
		     when ''MON''	then 2
		     when ''TUESDAY''	then 3
		     when ''TUES''	then 3
		     when ''TUE''	then 3
		     when ''WEDNESDAY'' then 4
		     when ''WED''	then 4
		     when ''WEDS''	then 4
		     when ''THURSDAY''  then 5
		     when ''THURS''	then 5
		     when ''THUR''	then 5
		     when ''THU''	then 5
		     when ''FRIDAY''	then 6
		     when ''FRI''	then 6
		     when ''SATURDAY''	then 7
		     when ''SAT''	then 7
		     else -1
		end) into v_dow
       from dual;
	
       if v_dow < 0 
       then 
	   raise exception ''Day of the week unknown'';
       end if;

       return v_dow;

end;' language 'plpgsql';


create function to_interval (
       --
       -- Convert an integer to the specified interval
       --
       -- Utility function so we do not have to remember how to escape
       -- double quotes when we typecast an integer to an interval
       --
       -- @author jowell@jsabino.com
       --
       -- @param interval_number	Integer to convert to interval
       -- @param interval_units		Interval units
       --
       -- @return interval equivalent of interval_number, in interval_units units
       --       
       integer,
       varchar
)
returns interval as '	
declare    
       interval__number	     alias for $1;
       interval__units	     alias for $2;
begin

	-- We should probably do unit checking at some point
	return ('''''''' || interval__number || '' '' || interval__units || '''''''')::interval;

end;' language 'plpgsql';


create function next_day (
       --
       -- Equivalent of Oracle next_day function
       --
       -- @author jowell@jsabino.com
       --
       -- @param somedate	Reference date
       -- @param weekday	Day of the week to find
       --
       -- @return The date of the next weekday that is later than somedate
       --
       timestamptz,   -- somedate
       varchar	      -- weekday 	      
)
returns timestamptz as '
declare
       next_day__somedate	alias for $1;
       next_day__weekday	alias for $2;
       v_dow			integer;
       v_ref_dow		integer;
       v_add_days		integer;
begin
	-- I cant find a function that converts days of the week to
	-- the corresponding integer value, so I roll my own (above)
	-- We avoid extract(dow from timestamp) because of incompatible output with to_char.
	v_ref_dow := dow_to_int(next_day__weekday);
	v_dow := to_number(to_char(next_day__somedate,''D''),''9'');
	
	-- If next_day___weekday is the same day of the week as
	-- next_day__somedate, we add a full week.
	if v_dow < v_ref_dow
	then
	     v_add_days := v_ref_dow - v_dow;
        else
	     v_add_days := v_ref_dow - v_dow + 7;
	end if;

	-- Do date math
	return next_day__somedate + to_interval(v_add_days,''days'');

end;' language 'plpgsql';

create function add_months (
       --
       -- Equivalent of Oracle add_months function
       --
       -- @author jowell@jsabino.com
       --
       -- @param somedate	Reference date
       -- @param n_months	Day of the week to find
       --
       -- @return The date plus n_months full months
       --
       timestamptz, 
       integer
)
returns timestamptz as '
declare
       add_months__somedate	alias for $1;
       add_months__n_months	alias for $2;
begin

	-- Date math magic
	return add_months__somedate + to_interval(add_months__n_months,''months'');

end;' language 'plpgsql';

create function last_day (
       --
       -- Equivalent of Oracle last_day function
       --
       -- @author jowell@jsabino.com
       --
       -- @param somedate	Reference date
       --
       -- @return The last day of the month containing somedate
       --
       timestamptz
)
returns timestamptz as '
declare
       last_day__somedate	alias for $1;
       v_month			integer;
       v_targetmonth		integer;
       v_date			timestamptz;
       v_targetdate		timestamptz;
begin
	
       -- Initial values
       v_targetdate := last_day__somedate;
       v_targetmonth := extract(month from last_day__somedate);

       -- Add up to 31 days to the given date, stop if month changes.
       FOR i IN 1..31 LOOP

	    v_date := last_day__somedate + to_interval(i,''days'');
	    v_month := extract(month from v_date);

	    if v_month != v_targetmonth
	    then
		exit;
	    else
	       v_targetdate := v_date;
	    end if;

       END LOOP;
	
       return v_targetdate;

end;' language 'plpgsql';



