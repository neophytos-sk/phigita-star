ad_library {

    Routines for background delivery of files

    @author Gustaf Neumann (neumann@wu-wien.ac.at)
    @creation-date 19 Nov 2005
    @cvs-id $Id: bgdelivery-procs.tcl,v 1.47 2013/03/21 21:58:05 gustafn Exp $
}

if {[info command ::thread::mutex] eq ""} {
  ns_log notice "libthread does not appear to be available, NOT loading bgdelivery"
  return
}
#return ;# DONT COMMIT

# catch {ns_conn contentsentlength} alone does not work, since we do not have
# a connection yet, and the bgdelivery won't be activated
catch {ns_conn xxxxx} msg
if {![string match *contentsentlength* $msg]} {
  ns_log notice "AOLserver is not patched for bgdelivery, NOT loading bgdelivery"

  ad_proc -public ad_returnfile_background {-client_data status_code mime_type filename} {
    Deliver the given file to the requestor in the background. This proc uses the
    background delivery thread to send the file in an event-driven manner without
    blocking a request thread. This is especially important when large files are 
    requested over slow (e.g. dial-ip) connections.
  } {
    ns_returnfile $status_code $mime_type $filename
  }
  return
}

::xotcl::THREAD create bgdelivery {

} -persistent 1 ;# -lightweight 1






bgdelivery ad_forward running {
  Interface to the background delivery thread to query the currently running deliveries.
  @return list of key value pairs of all currently running background processes
} %self do array get running


bgdelivery ad_forward nr_running {
  Interface to the background delivery thread to query the number of currently running deliveries.
  @return number of currently running background deliveries
} %self do array size running


bgdelivery forward write_headers ns_headers

proc util_backslash_escape {char string} {
    return [string map [list $char \\$char] $string]
}

bgdelivery ad_proc returnfile {
  {-client_data ""} 
  {-delete false} 
  {-content_disposition} 
  status_code mime_type filename} {
  Deliver the given file to the requestor in the background. This proc uses the
  background delivery thread to send the file in an event-driven manner without
  blocking a request thread. This is especially important when large files are 
  requested over slow (e.g. dial-ip) connections.
} {

 if {[info command ns_driversection] ne ""} {
     set use_writerThread [ns_config [ns_driversection] writerthreads 0]
 } else {
     set use_writerThread 0
 }

  if {[info exists content_disposition]} {
      set fn [util_backslash_escape \" $content_disposition]
      ns_set put [ns_conn outputheaders] Content-Disposition "attachment;filename=\"$fn\""
  }
  set size [file size $filename]


  # Make sure to set "connection close" for the reqests (in other
  # words, don't allow keep-alive, which is does not make sense, when
  # we close the connections manually in the bgdelivery thread).
  #
  if { !$use_writerThread} {
      ns_conn keepalive 0
  }

  set range [ns_set iget [ns_conn headers] range]
  if {[regexp {bytes=(.*)$} $range _ range]} {
    set ranges [list]
    set bytes 0
    set pos 0
    foreach r [split $range ,] {
      regexp {^(\d*)-(\d*)$} $r _ from to
      if {$from eq ""} {
	# The last $to bytes, $to must be specified; 'to' is
	# differently interpreted as in the case, where from is
	# non-empty
	set from [expr {$size - $to}]
      } else {
	if {$to eq ""} {set to [expr {$size-1}]}
      }
      set rangeSize [expr {1 + $to - $from}]
      lappend ranges [list $from $to $rangeSize]
      set pos [expr {$to + 1}]
      incr bytes $rangeSize
    }
  } else {
    set ranges ""
    set bytes $size
  }

  #
  # For the time being, we write the headers in a simplified version
  # directly in the spooling thread to avoid the overhead of double
  # h264opens.
  #

    #
    # Add content-range header for range requests.
    #
    if {[llength $ranges] == 1 && $status_code == 200} {
      lassign [lindex $ranges 0] from to
      ns_set put [ns_conn outputheaders] Content-Range "bytes $from-$to/$size"
      ns_log notice "added header-field Content-Range: bytes $from-$to/$size // $ranges"
      set status_code 206
    } elseif {[llength $ranges]>1} {
      ns_log warning "Multiple ranges are currently not supported, ignoring range request"
    }
    my write_headers $status_code $mime_type $bytes


  if {$bytes == 0} {
    # Tcl behaves different, when one tries to send 0 bytes via
    # file_copy. So, we handle this special case here...
    # There is actualy nothing to deliver....
    ns_set put [ns_conn outputheaders] "Content-Length" 0
    ns_return 200 $mime_type {}
    return
  }

  if {$use_writerThread } {
      if {$status_code == 206} {
	  #ns_log notice "ns_writer submitfile -offset $from -size $bytes $filename"
	  ns_writer submitfile -offset $from -size $bytes $filename
      } else {
	  #ns_log notice "ns_writer submitfile $filename"
	  ns_writer submitfile $filename
      }
      return
  }

  set errorMsg ""
  # Get the thread id and make sure the bgdelivery thread is already
  # running.
  set tid [my get_tid]
  
  # my log "+++ lock [my set bgmutex]"
  ::thread::mutex lock [my set mutex]

  #
  # Transfer the channel to the bgdelivery thread and report errors
  # in detail. 
  #
  # Notice, that Tcl versions up to 8.5.4 have a bug in this area.
  # If one uses an earlier version of Tcl, please apply:
  # http://tcl.cvs.sourceforge.net/viewvc/tcl/tcl/generic/tclIO.c?r1=1.61.2.29&r2=1.61.2.30&pathrev=core-8-4-branch
  #

  catch {
    set ch [ns_conn channel]
    if {[catch {thread::transfer $tid $ch} innerError]} {
      set channels_in_use "??"
      catch {set channels_in_use [bgdelivery do file channels]}
      ns_log error "thread transfer failed, channel=$ch, channels_in_use=$channels_in_use"
      error $innerError
    }
  } errorMsg
  
  ::thread::mutex unlock [my set mutex]
  
  if {$errorMsg ne ""} {
    error ERROR=$errorMsg
  }

  #my log "FILE SPOOL $filename"
ns_log error "TODO: file spool $filename - ::fileSpooler"
 #my do -async ::fileSpooler spool -ranges $ranges -delete $delete -channel $ch -filename $filename \
      -client_data $client_data

  #
  # set the length for the access log (which is written when the
  # connection thread is done)
  ns_conn contentsentlength $size       ;# maybe overly optimistic
}

ad_proc -public ad_returnfile_background {{-client_data ""} status_code mime_type filename} {
  Deliver the given file to the requestor in the background. This proc uses the
  background delivery thread to send the file in an event-driven manner without
  blocking a request thread. This is especially important when large files are 
  requested over slow (e.g. dial-ip) connections.
} {
    #ns_log notice "driver=[ns_conn driver]"
    if {[ns_conn driver] ne {nssock} } {
	ns_returnfile $status_code $mime_type $filename
    } else {
	bgdelivery returnfile -client_data $client_data $status_code $mime_type $filename
    }
}

