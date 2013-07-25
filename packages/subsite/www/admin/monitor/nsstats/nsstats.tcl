#
# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/.
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is AOLserver Code and related documentation
# distributed by AOL.
#
# The Initial Developer of the Original Code is America Online,
# Inc. Portions created by AOL are Copyright (C) 1999 America Online,
# Inc. All Rights Reserved.
#
# Alternatively, the contents of this file may be used under the terms
# of the GNU General Public License (the "GPL"), in which case the
# provisions of GPL are applicable instead of those above.  If you wish
# to allow use of your version of this file only under the terms of the
# GPL and not to allow others to use your version of this file under the
# License, indicate your decision by deleting the provisions above and
# replace them with the notice and other provisions required by the GPL.
# If you do not delete the provisions above, a recipient may use your
# version of this file under either the License or the GPL.
#

#
# nsstats.tcl --
#
#   Set of procedures implementing the NaviServer runtime statistics
#
#   To use it, set enabled to 1 and drop it somewehere under naviserver 
#   pageroot which is usually /usr/local/ns/pages and point browser to it
#

# If this pages needs to be restricted assign username and password here
set user ""
set password ""
set enabled 1

if { ![nsv_exists _ns_stats threads_0] } {
  nsv_set _ns_stats thread_0      "OK"
  nsv_set _ns_stats thread_-1     "ERROR"
  nsv_set _ns_stats thread_-2     "TIMEOUT"
  nsv_set _ns_stats thread_200    "MAXTLS"
  nsv_set _ns_stats thread_1      "DETACHED"
  nsv_set _ns_stats thread_2      "JOINED"
  nsv_set _ns_stats thread_4      "EXITED"
  nsv_set _ns_stats thread_32     "NAMESIZE"

  nsv_set _ns_stats sched_1       "thread"
  nsv_set _ns_stats sched_2       "once"
  nsv_set _ns_stats sched_4       "daily"
  nsv_set _ns_stats sched_8       "weekly"
  nsv_set _ns_stats sched_16      "paused"
  nsv_set _ns_stats sched_32      "running"

  nsv_set _ns_stats sched_thread  1
  nsv_set _ns_stats sched_once    2
  nsv_set _ns_stats sched_daily   4
  nsv_set _ns_stats sched_weekly  8
  nsv_set _ns_stats sched_paused  16
  nsv_set _ns_stats sched_running 32
}

proc _ns_stats.header {{stat ""}} {
    if {[string length $stat]} {
        set title "Naviserver Stats: [ns_info hostname] - $stat"
        set nav "<a href='?@page=index'><font color=#ffffff>Main Menu</font></a> &gt; <font color=#ffcc00>$stat</font>"
    } else {
        set title "Naviserver Stats: [ns_info hostname]"
        set nav "<font color=#ffcc00><font color=#ffcc00>Main Menu</font>"
    }

    return "\
    <html>
    <head>
    <title>$title</title>
    <style>
        body    { font-family: verdana,arial,helvetica,sans-serif; font-size: 8pt; color: #000000; background-color: #ffffff; }
        td      { font-family: verdana,arial,helvetica,sans-serif; font-size: 8pt; }
        pre     { font-family: courier new, courier; font-size: 10pt; }
        form    { font-family: verdana,helvetica,arial,sans-serif; font-size: 10pt; }
        i       { font-style: italic; }
        b       { font-style: bold; }
        hl      { font-family: verdana,arial,helvetica,sans-serif; font-style: bold; font-size: 12pt; }
        small   { font-size: smaller; }
        td td.subtitle {text-align: right; font-style: italic; font-size: 7pt; background-color: #f5f5f5;}
        td.coltitle {text-align: right; background-color: eaeaea;}
        td.colsection {font-size: 12pt; font-style: bold;}
        td.colvalue {background-color: #ffffff;}
    </style>
    </head>

    <table border=0 cellpadding=5 cellspacing=0 width=\"100%\">
    <tr>
        <td valign=middle bgcolor=#666699><font size=1 color=#ffffff><b>$nav</b></font></td>
        <td valign=middle bgcolor=#666699 align=right><font size=1 color=#ffffff><b>[_ns_stats.fmtTime [ns_time]]</b></font></td>
    </tr>
    </table>
    <br>"
}

proc _ns_stats.footer {} {
    return "</body></html>"
}

proc _ns_stats.index {} {
    set html [_ns_stats.header]

    append html "\
    o <a href='?@page=adp'>ADP</a><br>
    o <a href='?@page=cache'>Cache</a><br>
    o <a href='?@page=configfile'>Config File</a><br>
    o <a href='?@page=configparams'>Config Parameters</a><br>
    o <a href='?@page=log'>Log</a><br>
    o <a href='?@page=mempools'>Memory</a><br>
    o <a href='?@page=locks'>Mutex Locks</a><br>
    o <a href='?@page=nsvlocks'>Nsv Locks</a><br>
    o <a href='?@page=process'>Process</a><br>
    o <a href='?@page=sched'>Scheduled Procedures</a><br>
    o <a href='?@page=threads'>Threads</a><br>
    o <a href='?@page=jobs'>Jobs</a><br>"

    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.adp {} {
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]

    set numericSort 1
    set colTitles   [list File Device Inode "Modify Time" "Ref Count" Evals Size Blocks Scripts]

    if {$col == 1} {
        set numericSort 0
    }

    set results ""

    foreach {file stats} [ns_adp_stats] {
        set s  ""

        foreach {k v} $stats {
            if {"mtime" eq $k} {
                lappend s [_ns_stats.fmtTime $v]
            } else {
                lappend s $v
            }
        }
        lappend results [concat $file $s]
    }

    set rows [_ns_stats.sortResults $results [expr {$col - 1}] $numericSort $reverseSort]

    set html [_ns_stats.header ADP]
    append html [_ns_stats.results $col $colTitles ?@page=adp $rows $reverseSort]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.cache {} {
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]

    set numericSort 1

    if {$col == 1} {
        set numericSort 0
    }

    set results ""
    array set t {saved ""}

    foreach cache [ns_cache_names] {
        array set t [ns_cache_stats $cache]
        lappend results [list $cache $t(maxsize) $t(size) \
		[format %.2f [expr {$t(size)*100.0/$t(maxsize)}]]% \
		$t(entries) $t(flushed) $t(hits) \
		[format %.0f [expr {$t(entries)>0 ? $t(hits)*1.0/$t(entries) : 0}]] \
		$t(missed) "$t(hitrate)%" $t(expired) $t(pruned) $t(saved)]
    }

    set colTitles   [list Cache Max Current Utilization Entries Flushes Hits Reuse Misses "Hit Rate" Expired Pruned Saved]
    set rows        [_ns_stats.sortResults $results [expr {$col - 1}] $numericSort $reverseSort]

    set html [_ns_stats.header Cache]
    append html [_ns_stats.results $col $colTitles ?@page=cache $rows $reverseSort {left right right right right right right right right right right right right}]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.locks {} {
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]

    set numericSort 1
    set colTitles   [list Name Owner ID Locks Busy Contention "Total Lock" "Avg Lock" "Total Wait" "Max Wait"]
    set rows        ""

    if {$col == 1 || $col == 2} {
        set numericSort 0
    }

    set results ""
    set sumWait 0

    foreach l [ns_info locks] {
        set name      [lindex $l 0]
        set owner     [lindex $l 1]
        set id        [lindex $l 2]
        set nlock     [lindex $l 3]
        set nbusy     [lindex $l 4]
        set totalWait [lindex $l 5]
        set maxWait   [lindex $l 6]
        set sumWait   [expr {$sumWait + $totalWait}]
        set totalLock [lindex $l 7]
        set avgLock   [expr {$totalLock ne "" && $nlock > 0 ? $totalLock * 1.0 / $nlock : 0}]

        if {$nbusy == 0} {
            set contention 0.0
        } else {
            set contention [format %5.4f [expr {double($nbusy*100.0/$nlock)}]]
        }

        lappend results [list $name $owner $id $nlock $nbusy $contention $totalLock $avgLock $totalWait $maxWait]
    }

    foreach result [_ns_stats.sortResults $results [expr {$col - 1}] $numericSort $reverseSort] {
        set name        [lindex $result 0]
        set owner       [lindex $result 1]
        set id          [lindex $result 2]
        set nlock       [lindex $result 3]
        set nbusy       [lindex $result 4]
        set contention  [format %.4f [lindex $result 5]]
        set totalLock   [format %.4f [lindex $result 6]]
        set avgLock     [format %.4f [lindex $result 7]]
        set totalWait   [lindex $result 8]
        set maxWait     [lindex $result 9]
        set relWait     [expr {$sumWait > 0 ? $totalWait/$sumWait : 0}]

        set color black
        set ccolor [expr {$contention < 2   ? $color : $contention < 5   ? "orange" : "red"}]
        set tcolor [expr {$relWait    < 0.1 ? $color : $totalWait  < 0.5 ? "orange" : "red"}]
        set wcolor [expr {$maxWait    < 0.1 ? $color : $maxWait    < 1   ? "orange" : "red"}]
        set ncolor [expr {$ccolor eq "orange" || $tcolor eq "orange" || $wcolor eq "orange" ? "orange" : $color}]
        set ncolor [expr {$ccolor eq "red"    || $tcolor eq "red"    || $wcolor eq "red"    ? "red" : $ncolor}]

        lappend rows [list \
			  "<font color=$ncolor>$name</font>" \
			  "<font color=$color>$owner</font>" \
			  "<font color=$color>$id</font>" \
			  "<font color=$color>$nlock</font>" \
			  "<font color=$color>$nbusy</font>" \
			  "<font color=$ccolor>$contention</font>" \
			  "<font color=$color>$totalLock</font>" \
			  "<font color=$color>$avgLock</font>" \
			  "<font color=$tcolor>$totalWait</font>" \
			  "<font color=$wcolor>$maxWait</font>" \
			 ]
    }

    set html [_ns_stats.header "Mutex Locks"]
    append html [_ns_stats.results $col $colTitles ?@page=locks $rows $reverseSort \
		     {left left right right right right right right right right}]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.nsvlocks {} {
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]
    set all         [ns_queryget all 0]

    set numericSort 1
    set colTitles   [list Array Locks Bucket "Bucket Locks" Busy Contention "Total Wait" "Max Wait"]
    set rows        ""

    if {$col == 1} {
        set numericSort 0
    }
     
    # get the lock statistics for nsvs
    foreach l [ns_info locks] {
        set name      [lindex $l 0]
        if {![regexp {^nsv:(\d+):} $name _ bucket]} continue
        #set id        [lindex $l 2]
        set nlock     [lindex $l 3]
        set nbusy     [lindex $l 4]
        set totalWait [lindex $l 5]
        set maxWait   [lindex $l 6]
        #set sumWait   [expr {$sumWait + $totalWait}]

        if {$nbusy == 0} {
            set contention 0.0
        } else {
            set contention [format %5.4f [expr {double($nbusy*100.0/$nlock)}]]
        }

        set mutexStats($bucket) [list $nlock $nbusy $contention $totalWait $maxWait]
    }

    set rows ""
    set bucketNr 0
    if {[info command nsv_bucket] ne ""} {
      foreach b [nsv_bucket] {
        foreach e $b {
	  lappend rows [eval lappend e $bucketNr $mutexStats($bucketNr)]
	}
        incr bucketNr
      }
    }
    set rows [_ns_stats.sortResults $rows [expr {$col - 1}] $numericSort $reverseSort]
    set max 200
    if {[llength $rows]>$max && !$all} {
       set rows [lrange $rows 0 $max]
       set truncated 1
    }

    set html [_ns_stats.header "Nsv Locks"]
    append html [_ns_stats.results $col $colTitles ?@page=nsvlocks \
		     $rows \
		     $reverseSort \
		     {left right right right right right right right}]

    if {[info exists truncated]} {
      append html "<a href='?@page=nsvlocks&col=$col&reversesort=$reverseSort&all=1'>...</a><br>"
    }
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.log {} {
    set log ""

    catch {
        set f [open [ns_info log]]
        seek $f 0 end
        set n [expr {[tell $f] -4000}]

        if {$n < 0} {
            set n 4000
        }

        seek $f $n
        gets $f
        set log [ns_quotehtml [read $f]]
        close $f
    }

    set html [_ns_stats.header Log]
    append html "<font size=2><pre>$log</pre></font>"
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.configparams {} {
  set out [list]
  foreach section [lsort [ns_configsections]] {
    # We want to have e.g. "aaa/pools" before "aaa/pool/foo",
    # therefore we map "/" to "" to put it in the collating sequence
    # after plain chars
    set name [string map {/ ~} [ns_set name $section]]

    array unset keys
    for { set i 0 } { $i < [ns_set size $section] } { incr i } {
      lappend keys([string tolower [ns_set key $section $i]]) [ns_set value $section $i]
    }

    set line ""
    foreach section_key [lsort [array names keys]] {
      lappend line "<tr><td class='coltitle'>$section_key:</td>\n\
	<td class='colvalue'>[join $keys($section_key) <br>]</td></tr>"
    }
    set table($name) [join $line \n]
  }
  set order {
    ns~parameters ns~encodings ns~mimetypes ns~fastpath ns~threads .br
    ns~modules ns~module~.* .br
    ns~servers ns~server~.* .br
    ns~db~drivers ns~db~driver~* .br
    ns~db~pools ns~db~pool~* .br
  }

  set toc ""
  set sectionhtml ""
  foreach e $order {
    if {$e eq ".br"} {append sectionhtml "<tr><td colspan='2'>&nbsp</td></tr>\n"}
    foreach section [lsort [array names table -regexp $e]] {
      set name [string map {~ /} $section]
      lappend toc "<a href='#ref-$name'>$name</a>"
      set anchor "<a name='ref-$name'>$name</a>"
      append sectionhtml "\n<tr><td colspan='2' class='colsection'>$anchor</td></tr>\n$table($section)\n"
      unset table($section)
    }
  }
  if {[array size table] > 0} {
    append sectionhtml "\n<tr><td colspan='2' class='colsection'>Extra Parameters</td></tr>\n\n"
    foreach section [lsort [array names table]] {
      set name [string map {~ /} $section]
      lappend toc "<a href='#ref-$name'>$name</a>"
      set anchor "<a name='ref-$name'>$name</a>"
      append sectionhtml "\n<tr><td colspan='2' class='colsection'>$anchor</td></tr>\n$table($section)\n"
    }
  }
  set html [_ns_stats.header "Config Parameters"]
  append html "The following values are defined in the configuration database:<br>"
  append html "<table><tr><td valign='top'>"
  append html "<ul><li>[join $toc </li><li>]</li></ul>"
  append html "</td><td>"
  append html <table>$sectionhtml</table>
  append html "</td></tr>"
  append html [_ns_stats.footer]
  return $html
}

proc _ns_stats.configfile {} {
    set config ""
    set configFile [ns_info config]
    if {$configFile ne ""} {
	catch {
	    set f [open $configFile]
	    set config [read $f]
	    close $f
	}
    }
    set html [_ns_stats.header Log]
    append html "<font size=2><pre>[ns_quotehtml $config]</pre></font>"
    append html [_ns_stats.footer]

    return $html
}

# minimal backwards compatibility for tcl 8.4

if {[info command ::dict] ne ""} {
  proc dictget? {dict key {def ""}} {
    if {[dict exists $dict $key]} {
	return [dict get $dict $key]
    } else {
	return $def
    }
  }
} else {
  proc dictget? {dict key {def ""}} {
    return $key
  }
}


proc _ns_stats.mempools {} {
    set talloc 0
    set trequest 0
    set tused 0
    set tlocks 0
    set twaits 0
    set tfree 0
    set tops 0
    set ov 0
    set op 0
    set av 0

    set html [_ns_stats.header Memory]

    if {[info command ::dict] ne ""} {
        set trans [dict create]
        foreach thread [ns_info threads] {
          dict set trans thread0x[lindex $thread 2] [lindex $thread 0]
	}
    }

    append html "\
    <table border=0 cellpadding=0 cellspacing=0>
    <tr>
        <td valign=middle>"

    foreach p [lsort [ns_info pools]] {
        append html "\
        <b>[lindex $p 0]:</b>
        <b>[dictget? $trans [lindex $p 0]]</b>
        <br><br>
        <table border=0 cellpadding=0 cellspacing=1 bgcolor=#cccccc width=\"100%\">
        <tr>
            <td valign=middle align=center>
            <table border=0 cellpadding=4 cellspacing=1 width=\"100%\">
            <tr>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Block Size</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Frees</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Gets</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Puts</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Bytes Req</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Bytes Used</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Overhead</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Locks</font></td>
                <td valign=middle bgcolor=#999999><font color=#ffffff>Lock Waits</font></td>
             </tr>"

	    foreach b [lrange $p 1 end] {
		    set bs [lindex $b 0]
		    set nf [lindex $b 1]
		    set ng [lindex $b 2]
		    set np [lindex $b 3]
		    set nr [lindex $b 4]
		    set nu [expr {$ng - $np}]
		    set na [expr {$nu * $bs}]

		    incr tops [expr {$ng + $np}]
		    incr tlocks [lindex $b 5]
		    incr twaits [lindex $b 6]
		    incr tfree [expr {$bs * $nf}]
		    incr talloc $na
		    incr trequest $nr
		    incr tused $nu

		    if {$nr != 0} {
			    set ov [expr {$na - $nr}]
			    set op [format %4.2f%% [expr {double($ov) * 100 / $nr}]]
		    } else {
			    set ov "N/A"
			    set op "N/A"
		    }

		    append html "<tr>"

		    foreach e [linsert [lreplace $b 4 4] 4 $nr $na $op] {
			    append html "<td bgcolor=#ffffff>$e</td>"
		    }

		    append html "</tr>"
	    }

	    append html "\
	        </table>
	        </td>
        </tr>
        </table>
        <br>"
    }

    if { $trequest > 0 } {
        set ov [expr {$talloc - $trequest}]
        set op [format %4.2f [expr {double($ov) * 100 / $trequest}]]
    }
    if { $tops > 0 } {
    	set av [format %4.2f [expr {double(100) - (double($tlocks) * 100) / $tops}]]
    }
    if { $tlocks > 0 } {
	set wr [format %4.2f [expr {double($twaits) / $tlocks}]]
    } else {
	set wr N/A
    }

    append html "\
        </td>
    </tr>
    <tr>
        <td valign=middle>
        <b>Totals:</b><br><br>
        <table>
            <tr><td>Bytes Requested:</td><td>$trequest</td></tr>
            <tr><td>Bytes Free:</td><td>$tfree</td></tr>
            <tr><td>Bytes Allocated:</td><td>$talloc</td></tr>
            <tr><td>Bytes Wasted:</td><td>$ov</td></tr>
            <tr><td>Byte Overhead:</td><td>${op}%</td></tr>
            <tr><td>Mutex Locks:</td><td>$tlocks</td></tr>
            <tr><td>Mutex Lock Waits:</td><td>$twaits</td></tr>
            <tr><td>Lock Wait Ratio:</td><td>${wr}%</td></tr>
            <tr><td>Gets/Puts:</td><td>${tops}</td></tr>
            <tr><td>Lock Avoidance:</td><td>${av}%</td></tr>
        </table>
        </td>
    </tr>
    </table>"

    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.process.table {values} {
    set html "\
    <table border=0 cellpadding=0 cellspacing=1 bgcolor=#cccccc>
    <tr>
        <td valign=middle align=center>
        <table border=0 cellpadding=3 cellspacing=1 width=\"100%\">
        <tr>
            <td valign=middle bgcolor=#999999><font face=verdana size=1 color=#ffffff><nobr>Key</nobr></font></td>
            <td valign=middle bgcolor=#999999><font face=verdana size=1 color=#ffffff><nobr>Value</nobr></font></td>
        </tr>"

    foreach {key value} $values {
	append html "\
            <tr>
                <td class='coltitle'>$key</td>
                <td class='colvalue'>$value</td>
            </tr>"
    }

    append html "\
        </table>
        </td>
    </tr>
    </table>"
    return $html
}

proc _ns_stats.process {} {
    set values [list \
		    Host 		"[ns_info hostname] ([ns_info address])" \
		    "Boot Time"		[clock format [ns_info boottime] -format %c] \
		    Uptime		[_ns_stats.fmtSeconds [ns_info uptime]] \
		    Process		"[ns_info pid] [ns_info nsd]" \
		    Home 		[ns_info home] \
		    Configuration 	[ns_info config] \
		    "Error Log"		[ns_info log] \
		    Version 		"[ns_info patchlevel] (tag [ns_info tag]))" \
		    "Build Date" 	[ns_info builddate] \
		    Servers 		[join [ns_info servers] <br>] \
		    Callbacks 		[join [ns_info callbacks] <br>] \
		    "Socket Callbacks"	[join [ns_info sockcallbacks] <br>] \
		   ]

    set html [_ns_stats.header Process]

    append html [_ns_stats.process.table $values]

    foreach s [ns_info servers] {
	set requests ""; set addresses ""; set writerThreads ""
	foreach driver {nssock nsssl} {
	    set section [ns_driversection -driver $driver -server $s]
	    if {$section eq ""} continue
	    set addr [ns_config ns/module/$driver/servers $s]
	    if {$addr ne ""} {
		lappend addresses $addr
		lappend writerThreads $driver: [ns_config $section writerthreads 0]
	    } else {
		set port [ns_config $section port]
		if {$port ne ""} {
		    lappend addresses [ns_config $section address]:$port
		    lappend writerThreads $driver: [ns_config $section writerthreads 0]
		}
	    }
	}
	set serverdir ""
	catch {set serverdir [ns_server -server $s serverdir]}

	#
	# per pool information
	#
        set poolItems ""
	foreach pool [lsort [ns_server -server $s pools]] {
	    #
	    # provide a nicer name for the pool
	    #
	    set poolLabel "default"
	    if {$pool ne {}} {set poolLabel $pool}
	    #
	    # statistics
	    #
	    set rawstats [ns_server -server $s -pool $pool stats]
	    set rawthreads [concat [ns_server -server $s -pool $pool threads] \
				waiting [ns_server -server $s -pool $pool waiting]]
	    set rawreqs [join [ns_server -server $s -pool $pool all] <br>]

	    array set stats $rawstats
	    set item \
		"<tr bgcolor='#ffffff'><td class='subtitle'>Connection Threads:</td><td>$rawthreads</td></tr>\n"
	    if {$stats(requests) > 0} {
		append item "<tr bgcolor=#ffffff><td class='subtitle'>Request Handling:</td>" \
		    "<td>requests $stats(requests), "\
		    "queued $stats(queued) ([format %.2f [expr {$stats(queued)*100.0/$stats(requests)}]]%)," \
		    " spooled $stats(spools) ([format %.2f [expr {$stats(spools)*100.0/$stats(requests)}]]%)</td></tr>\n"
		append item "<tr bgcolor=#ffffff><td class='subtitle'>Request Timing:</td>" \
		    "<td>avg queue time [format %5.4f [expr {$stats(queuetime)*1.0/$stats(requests)}]]s," \
		    " avg filter time [format %5.4f [expr {$stats(filtertime)*1.0/$stats(requests)}]]s," \
		    " avg run time [format %.4f [expr {$stats(runtime)*1.0/$stats(requests)}]]s" \
		    "</td></tr>\n"
	    }
	    append item \
	          "<tr bgcolor='#ffffff'><td class='subtitle'>Active Requests:</td><td>$rawreqs</td></tr>\n"

	    lappend poolItems "Pool '$poolLabel'" "<table bgcolor='#eeeeee'>$item</table>"
	}

	set values [list \
			"Address"            [join $addresses <br>] \
			"Server Directory"   $serverdir \
			"Page Directory"     [ns_server -server $s pagedir] \
			"Tcl Library" 	     [ns_server -server $s tcllib] \
			"Access Log" 	     [ns_config ns/server/$s/module/nslog file] \
			"Writer Threads"     $writerThreads \
			"Connection Pools"   [ns_server -server $s pools] \
			{*}$poolItems \
			"Active Writer Jobs" [join [ns_writer list -server $s] <br>] \
		       ]
		
	append html \
	    "<h2>Server $s</h2>" \n \
	    [_ns_stats.process.table $values]
    }

    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.sched {} {
    set col             [ns_queryget col 1]
    set reverseSort     [ns_queryget reversesort 1]

    set numericSort     1
    set scheduledProcs  ""

    foreach s [ns_info scheduled] {
        set id          [lindex $s 0]
        set flags       [lindex $s 1]
        set next        [lindex $s 3]
        set lastqueue   [lindex $s 4]
        set laststart   [lindex $s 5]
        set lastend     [lindex $s 6]
        set proc        [lindex $s 7]
        set arg         [lrange $s 8 end]

        if [catch {
            set duration [expr {$lastend - $laststart}]
        }] {
            set duration "0"
        }

        set state "pending"

        if {[_ns_stats.isThreadSuspended $flags]} {
            set state suspended
        }

        if {[_ns_stats.isThreadRunning $flags]} {
            set state running
        }

        lappend scheduledProcs [list $id $state $proc $arg $flags $lastqueue $laststart $lastend $duration $next]
    }

    set rows ""

    foreach s [_ns_stats.sortResults $scheduledProcs [expr {$col - 1}] $numericSort $reverseSort] {
        set id          [lindex $s 0]
        set state       [lindex $s 1]
        set flags       [join [_ns_stats.getSchedFlagTypes [lindex $s 4]] "<br>"]
        set next        [_ns_stats.fmtTime [lindex $s 9]]
	set lastqueue   [_ns_stats.fmtTime [lindex $s 5]]
	set laststart   [_ns_stats.fmtTime [lindex $s 6]]
	set lastend     [_ns_stats.fmtTime [lindex $s 7]]
	set proc        [lindex $s 2]
        set arg         [lindex $s 3]
        set duration    [_ns_stats.fmtSeconds [lindex $s 8]]

        lappend rows [list $id $state $proc $arg $flags $lastqueue $laststart $lastend $duration $next]
    }

    set colTitles [list ID Status Callback Data Flags "Last Queue" "Last Start" "Last End" Duration "Next Run"]

    set html [_ns_stats.header "Scheduled Procedures"]
    append html [_ns_stats.results $col $colTitles ?@page=sched $rows $reverseSort]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.threads {} {
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]

    set pid [pid]
    set threadInfo [ns_info threads]
    if {[file readable /proc/$pid/statm] && [llength [lindex $threadInfo 0]] > 7} {
       set colNumSort  {. 0 0 1 1 1 0 0 1 1 0}
       set colTitles   {Thread Parent ID    Flags "Create Time" TID   State utime stime Args}
       set align       {left   left   right left   left         right right right right left}
       set osInfo      1
       set HZ          100  ;# for more reliable handling, we should implememnt jiffies_to_timespec or jiffies_to_secs in C
    } else {
       set colNumSort  {. 0 0 1 1 1 0}
       set colTitles   {Thread Parent ID    Flags "Create Time" Args}
       set align       {left   left   right left   left         left}
       set osInfo      0
    }
  
    if {$osInfo} {
        set ti {}
        foreach t $threadInfo {
            set fn /proc/$pid/task/[lindex $t 7]/stat
            if {[file readable $fn]} {
                set f [open $fn]; set s [read $f]; close $f
            } elseif {[file readable /proc/$pid/task/$pid/stat]} {
                set f [open /proc/$pid/task/$pid/stat]; set s [read $f]; close $f
            } else {
                set s ""
            }
            if {$s ne ""} {
                lassign $s tid comm state ppid pgrp session tty_nr tpgid flags minflt \
                  cminflt majflt cmajflt utime stime cutime cstime priority nice \
                  numthreads itrealval starttime vsize rss rsslim startcode endcode \
                  startstack kstkesp kstkeip signal blocked sigignore sigcatch wchan \
                  nswap cnswap ext_signal processor
                set state "$state [format %.2d $processor]"
            } else {
              lassign {} tid state 
              lassign {0 0} utime stime
           }
           lappend ti [linsert $t 5 $tid $state $utime $stime]
        }
        set threadInfo $ti
    }

    set rows ""
    foreach t [_ns_stats.sortResults $threadInfo [expr {$col - 1}] [lindex $colNumSort $col] $reverseSort] {
        set thread  [lindex $t 0]
        set parent  [lindex $t 1]
        set id      [lindex $t 2]
        set flags   [_ns_stats.getThreadType [lindex $t 3]]
        set create  [_ns_stats.fmtTime [lindex $t 4]]
        if {$osInfo} {
            set tid     [lindex $t 5]
            set state   [lindex $t 6]
            set utime   [lindex $t 7]
            set stime   [lindex $t 8]
            set proc    [lindex $t 9]
            set arg     [lindex $t 10]
            if {"p:0x0" eq $proc} { set proc "NULL" }
            if {"a:0x0" eq $arg} { set arg "NULL" }
            set stime [format %.3f [expr {$stime*1.0/$HZ}]]
            set utime [format %.3f [expr {$utime*1.0/$HZ}]]
            lappend rows [list $thread $parent $id $flags $create $tid $state $utime $stime $arg]
        } else {
            set proc    [lindex $t 5]
            set arg     [lindex $t 6]
            if {"p:0x0" eq $proc} { set proc "NULL" }
            if {"a:0x0" eq $arg} { set arg "NULL" }
            lappend rows [list $thread $parent $id $flags $create $arg]
        }
    }

    set html [_ns_stats.header Threads]
    append html [_ns_stats.results $col $colTitles ?@page=threads $rows $reverseSort $align]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.jobs {} {
    set queue       [ns_queryget queue]
    set col         [ns_queryget col 1]
    set reverseSort [ns_queryget reversesort 1]

    set numericSort 1
    set rows        [list]

    if { $queue == "" } {

      if {$col == 0 || $col == 1 || $col == 4} {
          set numericSort 0
      }

      set colTitles [list Name Desc maxThreads numRunning Req]

      foreach ql [ns_job queuelist] {
        array set qa $ql
        set name "<a href='?@page=jobs&queue=$qa(name)'>$qa(name)</a>"
        lappend results [list $name $qa(desc) $qa(maxthreads) $qa(numrunning) $qa(req)]
      }

      set rows [_ns_stats.sortResults $results [expr {$col - 1}] $numericSort $reverseSort]

    } else {

      if {$col == 0 || $col == 1 || $col == 2 || $col == 3 || $col == 4} {
          set numericSort 0
      }

      set colTitles   [list ID State Script Code Type Started Stopped Time]
      set results     [list]

      foreach jl [ns_job joblist $queue] {
        array set ja $jl  
        set ja(starttime) [_ns_stats.fmtTime $ja(starttime)]
        set ja(endtime) [_ns_stats.fmtTime $ja(endtime)]
        set ja(time) "[expr [lindex [split $ja(time) .] 0]/1000] sec"
        lappend results [list $ja(id) $ja(state) $ja(script) $ja(code) $ja(type) $ja(starttime) $ja(endtime) $ja(time)]
      }

      set rows [_ns_stats.sortResults $results [expr {$col - 1}] $numericSort $reverseSort]
    }

    set html [_ns_stats.header Jobs]
    append html [_ns_stats.results $col $colTitles ?@page=jobs&queue=$queue $rows $reverseSort]
    append html [_ns_stats.footer]

    return $html
}

proc _ns_stats.results {{selectedColNum ""} {colTitles ""} {colUrl ""} {rows ""} {reverseSort ""} {colAlignment ""}} {
    set numCols [llength $colTitles]

    for {set colNum 1} {$colNum < [expr {$numCols + 1}]} {incr colNum} {
        if {$colNum == $selectedColNum} {
            set colHdrColor($colNum)        "#666666"
            set colHdrFontColor($colNum)    "#ffffff"
            set colColor($colNum)           "#ececec"
        } else {
            set colHdrColor($colNum)        "#999999"
            set colHdrFontColor($colNum)    "#ffffff"
            set colColor($colNum)           "#ffffff"
        }
    }

    set html "\
    <table border=0 cellpadding=0 cellspacing=1 bgcolor=#cccccc>
    <tr>
        <td valign='middle' align='center'>
        <table border='0' cellpadding='4' cellspacing='1' width='100%'>
        <tr>"

    set i 1

    foreach title $colTitles {
        set url $colUrl

        if {$i == $selectedColNum} {
            if {$reverseSort} {
                append url "&reversesort=0"
            } else {
                append url "&reversesort=1"
            }
        } else {
            append url "&reversesort=$reverseSort"
        }

        set colAlign "left"

        if {[llength $colAlignment]} {
            set align [lindex $colAlignment [expr {$i - 1}]]

            if {[string length $align]} {
                set colAlign $align
            }
        }

        append html "<td valign=middle align=$colAlign bgcolor=$colHdrColor($i)><a href='$url&col=$i'><font color=$colHdrFontColor($i)>$title</font></a></td>"

        incr i
    }

    append html "</tr>"

    foreach row $rows {
        set i 1

        append html "<tr>"

        foreach column $row {
            set colAlign "left"

            if {[llength $colAlignment]} {
                set align [lindex $colAlignment [expr {$i - 1}]]

                if {[string length $align]} {
                    set colAlign $align
                }
            }

            append html "<td bgcolor=$colColor($i) valign=top align=$colAlign>$column</td>"

            incr i
        }

        append html "</tr>"
    }

    append html "\
        </table>
        </td>
    </tr>
    </table>"

    return $html
}

proc _ns_stats.msg {type msg} {
    switch $type {
        "error" {
            set color "red"
        }
        "warning" {
            set color "orange"
        }
        "success" {
            set color "green"
        }
        default {
            set color "black"
        }
    }

    return "<font color=$color><b>[string toupper $type]:<br><br>$msg</b></font>"
}

proc _ns_stats.getValue {key} {
    if {![nsv_exists _ns_stats $key]} {
        return ""
    }

    return [nsv_get _ns_stats $key]
}

proc _ns_stats.getThreadType {flag} {
    return [_ns_stats.getValue thread_$flag]
}

proc _ns_stats.getSchedType {flag} {
    return [_ns_stats.getValue sched_$flag]
}

proc _ns_stats.getSchedFlag {type} {
    return [_ns_stats.getValue sched_$type]
}

proc _ns_stats.isThreadSuspended {flags} {
    return [expr {$flags & [_ns_stats.getSchedFlag paused]}]
}

proc _ns_stats.isThreadRunning {flags} {
    return [expr {$flags & [_ns_stats.getSchedFlag running]}]
}

proc _ns_stats.getSchedFlagTypes {flags} {
    if [expr {$flags & [_ns_stats.getSchedFlag once]}] {
        set types "once"
    } else {
        set types "repeating"
    }

    if [expr {$flags & [_ns_stats.getSchedFlag daily]}] {
        lappend types "daily"
    }

    if [expr {$flags & [_ns_stats.getSchedFlag weekly]}] {
        lappend types "weekly"
    }

    if [expr {$flags & [_ns_stats.getSchedFlag thread]}] {
        lappend types "thread"
    }

    return $types
}

proc _ns_stats.fmtSeconds {seconds} {
    if {$seconds < 60} {
        return "${seconds} (s)"
    }

    if {$seconds < 3600} {
        set mins [expr {$seconds/60}]
        set secs [expr {$seconds - ($mins * 60)}]

        return "${mins}:${secs} (m:s)"
    }

    set hours [expr {$seconds/3600}]
    set mins  [expr {($seconds - ($hours * 3600))/60}]
    set secs  [expr {$seconds - (($hours * 3600) + ($mins * 60))}]

    if {$hours > 24} {
	set days  [expr {$hours / 24}]
	set hours [expr {$hours % 24}]
	return "$days day[expr {$days<2 ? {} : {s}}] ${hours}:${mins}:${secs} (h:m:s)"
    } else {
	return "${hours}:${mins}:${secs} (h:m:s)"
    }
}

proc _ns_stats.fmtTime {time} {
    if {$time < 0} {
        return "never"
    }

    return [clock format $time -format "%H:%M:%S %m/%d/%Y"]
}

proc _ns_stats.sortResults {results field numeric {reverse 0}} {
    global _sortListTmp

    set _sortListTmp(field)     $field
    set _sortListTmp(numeric)   $numeric
    set _sortListTmp(reverse)   $reverse

    return [lsort -command _ns_stats.cmpField $results]
}

proc _ns_stats.cmpField {v1 v2} {
    global _sortListTmp

    set v1  [lindex $v1 $_sortListTmp(field)]
    set v2  [lindex $v2 $_sortListTmp(field)]

    if {$_sortListTmp(numeric)} {
        if {$_sortListTmp(reverse)} {
            set cmp [_ns_stats.cmpNumeric $v2 $v1]
        } else {
            set cmp [_ns_stats.cmpNumeric $v1 $v2]
        }
    } else {
        if {$_sortListTmp(reverse)} {
            set cmp [string compare $v2 $v1]
        } else {
            set cmp [string compare $v1 $v2]
        }
    }

    return $cmp
}

proc _ns_stats.cmpNumeric {n1 n2} {
    if {$n1 < $n2} {
        return -1
    } elseif {$n1 > $n2} {
        return 1
    }

    return 0
}

# Main processing logic
set page [ns_queryget @page]
if { [info command _ns_stats.$page] == "" } {
  set page index
}

# Check user access if configured
if { ($enabled == 0 && [ns_conn peeraddr] != "127.0.0.1") ||
     ($user != "" && ([ns_conn authuser] != $user || [ns_conn authpassword] != $password)) } {
  ns_returnunauthorized
  return
}
# Produce page
ns_set update [ns_conn outputheaders] "Expires" "now"
ns_return 200 text/html [_ns_stats.$page]

