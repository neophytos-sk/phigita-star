ad_library {

    Routines for background delivery of files

    @author Gustaf Neumann (neumann@wu-wien.ac.at)
    @creation-date 19 Nov 2005
    @cvs-id $Id: bgdelivery-procs.tcl,v 1.2 2006/04/09 00:09:51 gustafn Exp $
}

::xotcl::THREAD create bgstream {
    
    ###############
    # File delivery
    ###############
    set ::delivery_count 0
    

    proc deliver_to_end {filename fd ch bytes_per_timeframe bytes {error {}}} {

	#ns_log notice "deliver_to_end: filename=$filename fd=$fd ch=$ch bytes_per_timeframe=$bytes_per_timeframe bytes=$bytes error=$error"
	if { $error ne {} || [eof $fd]} {
	    end-delivery $filename $fd $ch
	} else {
	    fcopy $fd $ch -size $bytes_per_timeframe -command [list deliver_to_end $filename $fd $ch $bytes_per_timeframe]
	}

    }
    



    proc deliver {ch filename position context} {
	set fd [open $filename]
	fconfigure $fd -translation binary
	fconfigure $ch -translation binary
	seek $fd $position
	
	if { $position > 0 } {
	    puts -nonewline $ch "FLV\x1\x1\0\0\0\x9\0\0\0\x9"
	}

	deliver_to_end $filename $fd $ch 30000 0
	
	
	set ::running($ch,$filename) $context
	incr ::delivery_count
    }

    proc end-delivery {filename fd ch args} {
	#ns_log notice "--- end of delivery of $filename, $args"
	if {[catch {close $ch} e]} {ns_log notice "bgstream, closing channel for $filename, error: $e"}
	if {[catch {close $fd} e]} {ns_log notice "bgstream, closing file $filename, error: $e"}
	if {[catch {unset ::running($ch,$filename)} e]} {ns_log notice "bgstreamz, unsetting $ch,$filename, error: $e"}
    }


} -persistent 1

bgstream ad_forward running {
  Interface to the background delivery thread to query the currently running deliveries.
  @return list of key value pairs of all currently running background processes
} %self do array get running


bgstream ad_forward nr_running {
  Interface to the background delivery thread to query the number of currently running deliveries.
  @return number of currently running background deliveries
} %self do array size running

if {[ns_info name] eq "NaviServer" || [ns_info version] eq {4.99} } {
  bgstream forward write_headers ns_headers
} else {
  bgstream forward write_headers ns_headers DUMMY
}


bgstream ad_proc streamfile {statuscode mime_type filename position} {
  Deliver the given file to the requestor in the background. This proc uses the
  background delivery thread to send the file in an event-driven manner without
  blocking a request thread. This is especially important when large files are 
  requested over slow (e.g. dial-ip) connections.
} {
  #ns_log notice "statuscode = $statuscode, filename=$filename"
  set size [file size $filename]
  set contentsentlength [expr { $size - $position }]
  if { [my write_headers $statuscode $mime_type $contentsentlength] } {
    set ch [ns_conn channel]
    thread::transfer [my get_tid] $ch
    throttle get_context
    my do -async deliver $ch $filename $position \
	[list [throttle set requestor],[throttle set url] [ns_conn start]]
      ns_conn contentsentlength $contentsentlength       ;# maybe overly optimistic
  }
}

ad_proc -public ad_streamfile_background {statuscode mime_type filename position} {
  Deliver the given file to the requestor in the background. This proc uses the
  background delivery thread to send the file in an event-driven manner without
  blocking a request thread. This is especially important when large files are 
  requested over slow (e.g. dial-ip) connections.
} {
    bgstream streamfile $statuscode $mime_type $filename $position
    #ns_writer submitfile -headers $filename ;# NaviServer
}




