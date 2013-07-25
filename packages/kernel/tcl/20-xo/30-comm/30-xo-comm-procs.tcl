namespace eval ::xo {;}
namespace eval ::xo::comm {;}

Class ::xo::comm::CurlMultiHandle

::xo::comm::CurlMultiHandle instproc init {} {
    my instvar curlMultiHandle
    set curlMultiHandle [curl::multiinit]
}


::xo::comm::CurlMultiHandle instproc addHandle {o} {
    my instvar curlMultiHandle
    $o instvar curlHandle
    $curlMultiHandle addhandle $curlHandle
    my set curlHandleObjectList($curlHandle) "$o"
    $curlMultiHandle auto -command "[self] clearHandleObjectList"
}

::xo::comm::CurlMultiHandle instproc clearHandleObjectList {} {
    my instvar curlHandleObjectList curlMultiHandle

    while {1} {
	lassign [$curlMultiHandle getinfo] curlHandle state exit_code num_messages
	if { $curlHandle ne {} } {
	    ns_log notice "HERE: $curlHandle $state $exit_code $num_messages - [self] removeHandle $curlHandleObjectList($curlHandle)"
	    [self] removeHandle $curlHandleObjectList($curlHandle)
	    unset curlHandleObjectList($curlHandle)		
	} else {
	    break
	}
    }
}

::xo::comm::CurlMultiHandle instproc removeHandle {o} {
    my instvar curlMultiHandle
    $o instvar curlHandle
    $curlMultiHandle removehandle $curlHandle
}

::xo::comm::CurlMultiHandle instproc activeTransfers {} {
    my instvar curlMultiHandle
    return [$curlMultiHandle active]
}


::xo::comm::CurlMultiHandle instproc cleanup {} {
    my instvar curlMultiHandle
    set mutexid [ns_mutex create]
    ns_mutex lock $mutexid
    if {[info exists curlMutliHandle]} {
	$curlMultiHandle cleanup
	unset curlHandle
    }
    ns_mutex unlock $mutexid
}

::xo::comm::CurlMultiHandle instproc getinfo {args} {
    my instvar curlMultiHandle
    return [$curlMultiHandle getinfo]
}

::xo::comm::CurlMultiHandle instproc destroy {args} {
    my cleanup
    return [next]
}

::xo::comm::CurlMultiHandle instproc startTransfer {} {
    my instvar curlMultiHandle


    return 1
    while {1} {
	set runningTransfers [my perform]
	ns_log notice "runningTransfers: $runningTransfers"
	if {$runningTransfers>0} {
	    after 500
	} else {
	    break
	}
    }
}

::xo::comm::CurlMultiHandle instproc perform {} {
    my instvar curlMultiHandle

    if {[catch {$curlMultiHandle active} activeTransfers]} {
	#puts "Error checking active transfers: $activeTransfers"
	return -1
    }
    if {[catch {$curlMultiHandle perform} running]} {
	#puts "Error: $running"
	return 1
    }
    return $running
}




Class ::xo::comm::CurlHandle -parameter {
    url
    {timeout 30}
    {nosignal 1}
    {encoding identity}
    {followlocation 1}
    {maxredirs 3}
    {method "GET"}
    {useragent "XOBOT/0.1"}
}

::xo::comm::CurlHandle instproc init {} {

    my instvar curlHandle url useragent timeout nosignal encoding followlocation maxredirs curlResponseHeader curlResponseBody method

    # uriComposite: scheme host path port
    array set uriComposite [uri::split $url]

    my requireNamespace

    set curlHandle [curl::init]

    $curlHandle configure \
	-post [::util::decode [string toupper $method] POST 1 0] \
	-useragent $useragent \
	-timeout $timeout \
	-encoding $encoding \
	-followlocation $followlocation \
	-maxredirs $maxredirs \
	-nosignal $nosignal \
	-headervar [self]::curlResponseHeader \
	-bodyvar [self]::curlResponseBody \
	-url $url

    return [next]
}

::xo::comm::CurlHandle instproc get_header {name} {
    set headervar [self]::curlResponseHeader
    return [set ${headervar}(${name})]
}

::xo::comm::CurlHandle instproc perform {} {
    my instvar curlHandle
    return [$curlHandle perform]
}

::xo::comm::CurlHandle instproc getinfo {option} {
    my instvar curlHandle
    return [$curlHandle getinfo $option]
}

::xo::comm::CurlHandle instproc cleanup {} {
    my instvar curlHandle
    set mutexid [ns_mutex create]
    ns_mutex lock $mutexid
    if {[info exists curlHandle]} {
	$curlHandle cleanup
	unset curlHandle
    }
    ns_mutex unlock $mutexid
}

::xo::comm::CurlHandle instproc destroy {args} {
    my cleanup
    return [next]
}

