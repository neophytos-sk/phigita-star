################################################################################
################################################################################
####                                  tclcurl.tcl
################################################################################
################################################################################
## Includes the tcl part of TclCurl
################################################################################
################################################################################
## (c) 2015 Neophytos Demetriou
## (c) 2001-2009 Andres Garcia Garcia. fandom@telefonica.net
## See the file "license.terms" for information on usage and redistribution
## of this file and for a DISCLAIMER OF ALL WARRANTIES.
################################################################################
################################################################################

package require TclCurl

namespace eval curl {

    array set errorcode_messages {

        -4
        {empty html while fetching feed}

        -3
        {failed during information extraction from article}

        -2
        {dom parse error for article html}

        -1 
        {zero-length body}

        1 
        {Unsupported protocol. This build of TclCurl has no support for this protocol.}

        2 
        {Very early initialization code failed. This is likely to be and internal error or problem.}

        3
        {URL malformat. The syntax was not correct.}

        4
        {URL user malformatted. The user-part of the URL syntax was not correct.}

        5
        {Couldn't resolve proxy. The given proxy host could not be resolved.}

        6
        {Couldn't resolve host. The given remote host was not resolved.}

        7
        {Failed to connect to host or proxy.}

        8
        {FTP weird server reply. The server sent data TclCurl couldn't parse. The given remote server is probably not an OK FTP server.}

        9
        {We were denied access when trying to login to a FTP server or when trying to change working directory to the one given in the URL.}

        10
        {FTP user/password incorrect. Either one or both were not accepted by the server.}

        11
        {FTP weird PASS reply. TclCurl couldn't parse the reply sent to the PASS request.}

        12
        {FTP weird USER reply. TclCurl couldn't parse the reply sent to the USER request.}

        13
        {FTP weird PASV reply, TclCurl couldn't parse the reply sent to the PASV request.}

        14
        {FTP weird 227 format. TclCurl couldn't parse the 227-line the server sent.}

        15
        {FTP can't get host. Couldn't resolve the host IP we got in the 227-line.}

        16
        {FTP can't reconnect. A bad return code on either PASV or EPSV was sent by the FTP server, preventing TclCurl from being able to continue.}

        17
        {FTP couldn't set binary. Couldn't change transfer method to binary.}

        18
        {Partial file. Only a part of the file was transfered, this happens when the server first reports an expected transfer size and then delivers data that doesn't match the given size.}

        19
        {FTP couldn't RETR file, we either got a weird reply to a 'RETR' command or a zero byte transfer.}

        20
        {FTP write error. After a completed file transferm the FTP server did not respond properly.}

        21
        {FTP quote error. A custom 'QUOTE' returned error code 400 or higher from the server.}

        22
        {HTTP not found. The requested page was not found. This return code only appears if --fail is used and the HTTP server returns an error code that is 400 or higher.}

        23
        {Write error. TclCurl couldn't write data to a local filesystem or an error was returned from a write callback.}

        24
        {Malformat user. User name badly specified. Not in use anymore}

        25
        {FTP couldn't STOR file. The server denied the STOR operation, the error buffer will usually have the server explanation.}

        26
        {Read error. There was a problem reading from a local file or an error was returned from the read callback.}

        27
        {Out of memory. A memory allocation request failed. This should never happen unless something weird is going on in your computer.}

        28
        {Operation timeout. The specified time-out period was reached according to the conditions.}

        29
        {FTP couldn't set ASCII. The server returned an unknown reply.}

        30
        {FTP PORT command failed, this usually happens when you haven't specified a good enough address for TclCurl to use.}

        31
        {FTP couldn't use REST. This should never happen is the server is sane.}

        32
        {FTP couldn't use the SIZE command. The command is an extension to the original FTP spec RFC 959, so not all servers support it.}

        33
        {HTTP range error. The server doesn't support or accept range requests.}

        34
        {HTTP post error. Internal post-request generation error.}

        35
        {SSL connect error. The SSL handshaking failed, the error buffer may have a clue to the reason, could be certificates, passwords, ...}

        36
        {FTP bad download resume. Couldn't continue an earlier aborted download, probably because you are trying to resume beyond the file size.}

        37
        {A file given with FILE:// couldn't be read. Did you checked the permissions?}

        38
        {LDAP cannot bind. LDAP bind operation failed.}

        39
        {LDAP search failed.}

        40
        {Library not found. The LDAP library was not found.}

        41
        {A required LDAP function was not found.}

        42
        {Aborted by callback. An application told TclCurl to abort the operation.}

        43
        {Internal error. A function was called with a bad parameter.}

        44
        {Internal error. A function was called in a bad order.}

        45
        {Interface error. A specified outgoing interface could not be used.}

        46
        {Bad password entered. An error was signalled when the password was entered.}

        47
        {Too many redirects. When following redirects, TclCurl hit the maximum amount, set your limit with --maxredirs}

        48
        {Unknown TELNET option specified.}

        49
        {A telnet option string was illegally formatted.}

        50
        {Currently not used.}

        51
        {The remote peer's SSL certificate wasn't ok}

        52
        {The server didn't reply anything, which here is considered an error.}

        53
        {The specified crypto engine wasn't found.}

        54
        {Failed setting the selected SSL crypto engine as default!}

        55
        {Failed sending network data.}

        56
        {Failure with receiving network data.}

        57
        {Share is in use (internal error)}

        58
        {Problem with the local certificate}

        59
        {Couldn't use specified SSL cipher}

        60
        {Problem with the CA cert (path? permission?)}

        61
        {Unrecognized transfer encoding}

    }


}


################################################################################
# configure
#    Invokes the 'curl-config' script to be able to know what features have
#    been compiled in the installed version of libcurl.
#    Possible options are '-prefix', '-feature' and 'vernum'
################################################################################
proc ::curl::curlConfig {option} {

    if {$::tcl_platform(platform)=="windows"} {
        error "This command is not available in Windows"
    }

    switch -exact -- $option {
        -prefix {
            return [exec curl-config --prefix]
        }
        -feature {
            set featureList [exec curl-config --feature]
            regsub -all {\\n} $featureList { } featureList
            return $featureList
        }
        -vernum {
            return [exec curl-config --vernum]
        }
        -ca {
            return [exec curl-config --ca]
        }
        default {
            error "bad option '$option': must be '-prefix', '-feature', '-vernum' or '-ca'"
        }
    }
    return
}

################################################################################
# transfer
#    The transfer command is used for simple transfers in which you don't
#    want to request more than one file.
#
# Parameters:
#    Use the same parameters you would use in the 'configure' command to
#    configure the download and the same as in 'getinfo' with a 'info'
#    prefix to get info about the transfer.
################################################################################
proc ::curl::transfer {args} {
    variable getInfo
    variable curlBodyVar

    set i 0
    set newArgs ""
    catch {unset getInfo}

    foreach {option value} $args {
        set noPassOption 0
        set block        1
        switch -regexp -- $option {
            -info.* {
                set noPassOption 1
                regsub -- {-info} $option {} option
                set getInfo($option) $value
            }
            -block {
                set noPassOption 1
                set block $value
            }
            -bodyvar {
                upvar $value curlBodyVar
                set    value curlBodyVar
            }
            -headervar {
                upvar $value curlHeaderVar
                set    value curlHeaderVar
            }
            -errorbuffer {
                upvar $value curlErrorVar
                set    value curlErrorVar
            }
        }
        if {$noPassOption==0} {
            lappend newArgs $option $value
        }
    }

    if {[catch {::curl::init} curlHandle]} {
        error "Could not init a curl session: $curlHandle"
    }

    if {[catch {eval $curlHandle configure $newArgs} result]} {
        $curlHandle  cleanup
        error $result
    }

    if {$block==1} {
        if {[catch {$curlHandle perform} result]} {
           $curlHandle cleanup
           error $result
        }
        if {[info exists getInfo]} {
            foreach {option var} [array get getInfo] {
                upvar $var info
                set info [eval $curlHandle getinfo $option]
            }
        }
        if {[catch {$curlHandle cleanup} result]} {
            error $result
        }
    } else {
        # We create a multiHandle
        set multiHandle [curl::multiinit]

        # We add the easy handle to the multi handle.
        $multiHandle addhandle $curlHandle

        # So now we create the event source passing the multiHandle as a parameter.
        curl::createEventSource $multiHandle

        # And we return, it is non blocking after all.
    }
    return 0
}

