drop function trigrams(text);
create or replace function trigrams (text) returns text as $$
declare
   thetext alias for $1;
   v_retval text;
   v_last char;
   v_prev char;
   v_ch char;
   v_text text;
begin
   v_text := translate(thetext,' ','_');
   v_retval :='';
   v_last := '_';
   v_prev := substr(v_text,1,1);
   FOR i IN 2..char_length(v_text) LOOP
      -- some computations here
      -- RAISE NOTICE 'i is %', i;
	v_ch = substr(v_text,i,1);
	v_retval := v_retval || ' ' || v_last || v_prev || v_ch;
	v_last := v_prev;
	v_prev := v_ch;
   END LOOP;
   return v_retval;
end;
$$ language plpgsql;
