tmpl::master {
    h2 { t "Server Information" }
    table {
	foreach item {
	    server hostname address
	    pid uptime boottime
	    home config log pageroot tcllib
	    nsd argv0 name version label builddate platform
	} {
	    ## Note the catch so this works on all AOLserver revisions.
	    if [catch {
		set itemval [ns_info $item]
		if [regexp {boottime} $item] {
		    set itemval "[ns_httptime $itemval]"
		}
		tr {
		    td -align right -valign top {
			b { t $item: }
		    }
		    td -align left -valign top {
			t -disableOutputEscaping "$itemval &nbsp;"
		    }
		}
	    } errMsg] {
		## Catch commands that don't exist.
		tr {
		    td -align right {
			b { t $item: }
		    }
		    td -align left {
			t n/a
		    }
		}
		continue
	    }
	}
    }

    h2 { t "Scheduled Procs" }

    table {
	tr {
	    td -align left -valign bottom {
		b { t proc }
	    }
	    td -align left -valign bottom {
		b { t id }
	    }
	    td -align left -valign bottom {
		b { t flags }
	    }
	    td -align left -valign bottom {
		b { t interval }
	    }
	    td -align left -valign bottom {
		b { t nextqueue }
		br
		b { t lastqueue }
		br
		b { t laststart }
		br 
		b { t lastend }
	    }
	    td -align left -valign bottom {
		b { t arg }
	    }
	}
	foreach item [lsort [ns_info scheduled]] {
	    tr {

		## proc, id, flags, interval
		td -align left -valign top {
		    t -disableOutputEscaping "[lindex $item 7]&nbsp;"
		}
		for { set i 0 } { $i < 3 } { incr i } {
		    td -align left -valign top {
			t -disableOutputEscaping "[lindex $item $i]&nbsp;"
		    }
		}
		## times: nextqueue, lastqueue, laststart, lastend
		td -align left -valign top {
		    div {
			for { set i 3 } { $i < 7 } { incr i } {
			    t "[ns_httptime [lindex $item $i]]"
			    br
			}
		    }
		}

		## arg
		td -align left -valign top {
		    t -disableOutputEscaping "[lindex $item 8]&nbsp;<br>[lindex $item 9]"
		}
	    }
	}
    }

    h2 { t "Running Threads" }
    table {
	tr {
	    td -align left -valign bottom {
		b { t name }
	    }
	    td -align left -valign bottom {
		b { t parent }
	    }
	    td -align left -valign bottom {
		b { t tid }
	    }
	    td -align left -valign bottom {
		b { t flags }
	    }
	    td -align left -valign bottom {
		b { t ctime }
	    }
	    td -align left -valign bottom {
		b { t proc }
	    }
	    td -align left -valign bottom {
		b { t arg }
	    }
	}
	foreach item [lsort [ns_info threads]] {
	    tr {
		for { set i 0 } { $i < 7 } { incr i } {
		    td -align left -valign bottom {
			if { $i != 4 } {
			    t "[lindex $item $i]"
			} else {
			    t "[ns_httptime [lindex $item $i]]"
			}
		    }
		}
	    }
	}
    }

    h2 { t "VMSTAT"  }
    code {
    	t [exec vmstat]
    }

    h2 { t "ps -auxf" }
    code {
	t [exec ps auxf]
    }
}