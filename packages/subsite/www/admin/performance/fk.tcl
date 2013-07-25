ReturnHeaders text/plain

# Most of this stolen from 
# schema browser. 

# small change to sb_get_indexes so it will create a thing for the pk index as well.

foreach table_name [sb_get_tables_list] { 


    set complex_foreign_keys [list]
    set simple [list]
    db_foreach X "
         select t.tgargs as constraint_args,
             t.tgconstrname as constraint_name,
             'NOACTION' as action,
             'CHECK' as trigger_kind,
             r1.relname as refer_table,
             t.oid as oid,
             0 as sort_key
         from
             pg_trigger t,
             pg_class r,
             pg_class r1,
             pg_proc p
         where
             lower(r.relname) = lower(:table_name) and
             r.oid = t.tgrelid and
             r1.oid = t.tgconstrrelid and
             t.tgisconstraint and
             t.tgfoid = p.oid and
             p.proname = 'RI_FKey_check_ins'
         union all
         select t.tgargs as constraint_args,
             t.tgconstrname as constraint_name,
             case 
               when p.proname like '%noaction%' then 'NOACTION'
               when p.proname like '%cascade%' then 'CASCADE'
               when p.proname like '%setnull%' then 'SET NULL'
               when p.proname like '%setdefault%' then 'SET DEFAULT'
             end as action,
             case
               when p.proname like '%upd' then 'ON UPDATE'
               when p.proname like '%del' then 'ON DELETE'
             end as trigger_kind,
             r1.relname as refer_table,
             t.oid as oid,
             1 as sort_key
         from
             pg_trigger t,
             pg_class r,
             pg_class r1,
             pg_proc p
         where
             lower(r.relname) = lower(:table_name) and
             r.oid = t.tgconstrrelid and
             r1.oid = t.tgrelid and
             t.tgisconstraint and
             t.tgfoid = p.oid and
             not p.proname like 'RI%_check_%'
         order by oid, sort_key
       " {             
           set one_ri_datum [list]
           set arg_start 0
           while { ![empty_string_p $constraint_args] } {
               set arg_end [expr [string first "\\000" $constraint_args] - 1]
               lappend one_ri_datum [string range $constraint_args $arg_start $arg_end]
               set constraint_args [string range $constraint_args [expr $arg_end+5] end]
           }
           switch $trigger_kind {
               CHECK {
                   if { [info exists foreign_key_sql] } {
                       if { $arg_count == 1 } {
                           set references($on_var) $foreign_key_sql
                       } else {
                           lappend complex_foreign_keys $foreign_key_sql
                       }
                   }
                   if { [string equal $constraint_name "<unnamed>"] } {
                       set foreign_key_sql ""
                   } else {
                       set foreign_key_sql "CONSTRAINT $constraint_name "
                   }
                   set on_var_part [list]
                   set refer_var_part [list]
                   set arg_count 0
                   foreach { on_var refer_var } [lrange $one_ri_datum 4 end] {
                       lappend refer_var_part $refer_var
                       lappend on_var_part $on_var

                       incr arg_count
                   }
                   if { $arg_count > 1 } {
                       append foreign_key_sql "FOREIGN KEY ([join $on_var_part ","]) "
                   }
                   append foreign_key_sql "REFERENCES <a href=\"index?table_name=$refer_table\">$refer_table</a> ([join $refer_var_part ","])"
               }
               default {
                   if { ![string equal $action "NOACTION"] } {
                       append foreign_key_sql " $trigger_kind $action"
                   }
               }
           }
           set ref(${table_name}.[join $on_var_part ","]) [list CTABLE $table_name COLS $on_var_part CON $constraint_name PTABLE $refer_table PCOLS $refer_var_part]
       }
    if { [info exists foreign_key_sql] } {
        if { $arg_count == 1 } {
            set references($on_var) $foreign_key_sql
        } else {
            lappend complex_foreign_keys $foreign_key_sql
        }
    }
    #return [list [array get references] $complex_foreign_keys]
    if {[array exists ref]} {
        #ns_write   [join [array get ref] "\n"]\n\n
        foreach {key checklist} [array get ref] { 

            array set check $checklist 
            
            foreach tab [list $check(CTABLE) $check(PTABLE)] { 
                if {![info exists pki($tab)]} { 
                    if { [db_0or1row pkiget "
            select
              indkey as primary_key_array
            from
              pg_index i join (select oid from pg_class where relname = lower(:tab)) c
                on (i.indrelid = c.oid)
              join pg_class index_class on (index_class.oid = i.indexrelid and i.indisprimary)
              join pg_am a on (index_class.relam = a.oid)"] } {
                        set pki($tab) $primary_key_array
                    } else {
                        set pki($tab) [list]
                    }
                }
            }
 
            #ns_write [join [array get check]]\n\n

            set cdx "([join $check(COLS) ", "]"
            set pdx "([join $check(PCOLS) ", "]"
 

            if {[string first $cdx [util_memoize [list sb_get_indexes $check(CTABLE) f $pki($check(CTABLE))]]] < 0} { 
                if {[string length $check(CTABLE)_[join $check(COLS) "_"]_idx] > 30} { 
                    ns_write "-- "
                } 
                set idx "create index $check(CTABLE)_[join $check(COLS) "_"]_idx ON $check(CTABLE)$cdx);\n"
                if {![info exists crlist($idx)]} { 
                    ns_write $idx 
                    set crlist($idx) 1
                }
            }
            if {[string first $pdx [util_memoize [list sb_get_indexes $check(PTABLE) f $pki($check(PTABLE))]]] < 0} { 
                if {[string length $check(PTABLE)_[join $check(PCOLS) "_"]_idx] > 30} { 
                    ns_write "-- "
                } 
                set idx "create index $check(PTABLE)_[join $check(PCOLS) "_"]_idx ON $check(PTABLE)$pdx);\n"
                ns_write $idx
                if {![info exists crlist($idx)]} { 
                    ns_write $idx 
                    set crlist($idx) 1
                }
            }
        }

        unset ref
    }
}
