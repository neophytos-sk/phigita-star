namespace eval ::messaging {;}
namespace eval ::messaging::mms {;}


namespace eval ::util {;} 
proc ::util::itoa {} {
    return [format %c $i]
}

proc ::util::atoi {c} {
    scan $c %c v
    return $v
}



## The MMS header decoding class##

Class ::messaging::mms::Message -parameter {
    BCC 
    CC 
    CONTENTLOCATION 
    CONTENTTYPE 
    DATE 
    DELIVERYREPORT 
    DELIVERYTIME 
    EXPIRY 
    FROM 
    MESSAGECLASS 
    MESSAGEID 
    MESSAGETYPE 
    MMSVERSIONMAJOR 
    MMSVERSIONMINOR
    MESSAGESIZE 
    PRIORITY 
    READREPLY 
    REPORTALLOWED 
    RESPONSESTATUS 
    RESPONSETEXT 
    SENDERVISIBILITY 
    STATUS 
    SUBJECT 
    TO 
    TRANSACTIONID 
    MMSVERSIONRAW
    CONTENTTYPE_PARAMS
}




Class ::messaging::mms::RequestHandler -parameter {
    {data "[encoding convertfrom utf-8 [ns_conn content 0 [ns_conn contentlength]]]"}
    {headers "[ns_conn headers]"}
    {msg "[::messaging::mms::Message new]"}
}


## Constants                                          ##
##                                                    ##
## http://wapforum.org/                               ##
## WAP-209-MMSEncapsulation-20020105-a                ##
## Table 8                                            ##
##                                                    ##
## The values are enconded using WSP 7bit encoding.   ##
## Read more about how to decode this here:           ##
## http://www.nowsms.com/discus/messages/12/3287.html ##
##                                                    ##
## Example from the above adress:                     ##
## 7Bit 0D =  0001101                                 ##
## 8Bit 0D = 10001101 = 8D                            ##

::messaging::mms::RequestHandler array set mms "
    BCC			\x81 
    CC			\x82 
    CONTENT_LOCATION    \x83 
    CONTENT_TYPE	\x84 
    DATE		\x85 
    DELIVERY_REPORT	\x86 
    DELIVERY_TIME	\x87 
    EXPIRY	        \x88 
    FROM		\x89 
    MESSAGE_CLASS	\x8A 
    MESSAGE_ID		\x8B 
    MESSAGE_TYPE	\x8C 
    MMS_VERSION		\x8D 
    MESSAGE_SIZE	\x8E 
    PRIORITY		\x8F 
    READ_REPLY		\x90 
    REPORT_ALLOWED	\x91 
    RESPONSE_STATUS	\x92 
    RESPONSE_TEXT	\x93 
    SENDER_VISIBILITY	\x94 
    STATUS		\x95 
    SUBJECT		\x96 
    TO			\x97 
    TRANSACTION_ID	\x98 
"

foreach {key ch} [::messaging::mms::RequestHandler array get mms] {
    ::messaging::mms::RequestHandler set inverse_mms([::util::atoi $ch]) $key
}


## Array of header contents##

foreach {ch key} "
	\x80 m-send-req
	\x81 m-send-conf
	\x82 m-notification-ind
	\x83 m-notifyresp-ind
	\x84 m-retrieve-conf
	\x85 m-acknowledge-ind
	\x86 m-delivery-ind
	\x00 NULL
" {
    ::messaging::mms::RequestHandler set mmsMessageTypes([::util::atoi $ch]) $key
}


## Some other useful arrays##

# 0x80 TRUE  0x81 FALSE 0x00 NULL
::messaging::mms::RequestHandler array set mmsYesNo [list 128 1 129 0 0 NULL]


::messaging::mms::RequestHandler array set mmsPriority "
	\x80 Low
	\x81 Normal
	\x82 High
	\x00 NULL
"

foreach {ch cl} "
	\x80 Personal
	\x81 Advertisement
	\x82 Informational
	\x83 Auto
" {
    ::messaging::mms::RequestHandler set mmsMessageClass([::util::atoi $ch]) $cl
}

foreach {chr_i type} {
    0 */*
    1 text/*
    2 text/html
    3 text/plain
    4 text/x-hdml
    5 text/x-ttml
    6 text/x-vCalendar
    7 text/x-vCard
    8 text/vnd.wap.wml
    9 text/vnd.wap.wmlscript
    10 text/vnd.wap.wta-event
    11 multipart/*
    12 multipart/mixed
    13 multipart/form-data
    14 multipart/byterantes
    15 multipart/alternative
    16 application/*
    17 application/java-vm
    18 application/x-www-form-urlencoded
    19 application/x-hdmlc
    20 application/vnd.wap.wmlc
    21 application/vnd.wap.wmlscriptc
    22 application/vnd.wap.wta-eventc
    23 application/vnd.wap.uaprof
    24 application/vnd.wap.wtls-ca-certificate
    25 application/vnd.wap.wtls-user-certificate
    26 application/x-x509-ca-cert
    27 application/x-x509-user-cert
    28 image/*
    29 image/gif
    30 image/jpeg
    31 image/tiff
    32 image/png
    33 image/vnd.wap.wbmp
    34 application/vnd.wap.multipart.*
    35 application/vnd.wap.multipart.mixed
    36 application/vnd.wap.multipart.form-data
    37 application/vnd.wap.multipart.byteranges
    38 application/vnd.wap.multipart.alternative
    39 application/xml
    40 text/xml
    41 application/vnd.wap.wbxml
    42 application/x-x968-cross-cert
    43 application/x-x968-ca-cert
    44 application/x-x968-user-cert
    45 text/vnd.wap.si
    46 application/vnd.wap.sic
    47 text/vnd.wap.sl
    48 application/vnd.wap.slc
    49 text/vnd.wap.co
    50 application/vnd.wap.coc
    51 application/vnd.wap.multipart.related
    52 application/vnd.wap.sia
    53 text/vnd.wap.connectivity-xml
    54 application/vnd.wap.connectivity-wbxml
    55 application/pkcs7-mime
    56 application/vnd.wap.hashed-certificate
    57 application/vnd.wap.signed-certificate
    58 application/vnd.wap.cert-response
    59 application/xhtml+xml
    60 application/wml+xml
    61 text/css
    62 application/vnd.wap.mms-message
    63 application/vnd.wap.rollover-certificate
    64 application/vnd.wap.locc+wbxml
    65 application/vnd.wap.loc+xml
    66 application/vnd.syncml.dm+wbxml
    67 application/vnd.syncml.dm+xml
    68 application/vnd.syncml.notification
    69 application/vnd.wap.xhtml+xml
    70 application/vnd.wv.csp.cir
    71 application/vnd.oma.dd+xml
    72 application/vnd.oma.drm.message
    73 application/vnd.oma.drm.content
    74 application/vnd.oma.drm.rights+xml
    75 application/vnd.oma.drm.rights+wbxml
} {
    ::messaging::mms::RequestHandler set mmsContentTypes($chr_i) $type
}



::messaging::mms::RequestHandler instproc init {} {
    my instvar msg data pos
    set pos -1
    #set __asciidata [::util::hex_to_string [lindex $data 0]]
    my set parts [list]
    while {[my parseHeader]} {}

    # Header done, fetch parts, but make sure the header was parsed correctly
    if { [$msg CONTENTTYPE] eq {application/vnd.wap.multipart.related} || [$msg CONTENTTYPE] eq {application/vnd.wap.multipart.mixed} } {
	while { [my parseParts] } {}
	return 1
    } else {
	return 0
    }

}


## This function checks what kind of field is to be ##
## parsed at the moment                             ##
##                                                  ##
## If true is returned, the class will go on and    ##
## and continue decode the header. If false, the    ##
## class will end the header decoding.              ##

::messaging::mms::RequestHandler instproc parseHeader {} {
    my instvar msg data pos

    # Some global variables used
    [my info class] instvar mmsMessageTypes mmsYesNo mmsPriority mmsMessageClass mmsContentTypes inverse_mms

    # HERE: if !array_key_exists this->pos this->data
    # HERE: return 0


    set ch [string index $data [incr pos]]
    set chr_i [::util::atoi $ch]
    if { ![info exists inverse_mms($chr_i)] } {
	set prev_pos $pos            

	set debug ""
	foreach varName [$msg info vars] {
	    lappend debug [list $varName [$msg $varName]]
	}
	error "HERE parse error prev_pos=$prev_pos pos=$pos $chr_i [::util::string_to_hex $ch] $debug"
    }

    switch -exact -- $inverse_mms($chr_i) {
	BCC {
	    $msg BCC [my parseEncodedStringValue]
	}
	CC {
	    $msg CC [my parseEncodedStringValue]
	}
	CONTENT_LOCATION {
	    $msg CONTENTLOCATION [my parseTextString]
	}
	CONTENT_TYPE {
	    $msg CONTENTTYPE [my parseContentType]

	    # Ok, now we have parsed the content-type of the message, let's see if there are any parameters
	    set noparams 0
	    while { !$noparams } {
		set chr_i [::util::atoi [string index $data [incr pos]]]
		switch -exact -- $chr_i {
		    137 { 
			# Start, textstring
			$msg lappend CONTENTTYPE_PARAMS "type [my parseTextString]"
		    } 
		    138 {
			# type, constrained media
			set next_chr_i [::util::atoi [string index $data [expr {1+$pos}]]]
			if { $next_chr_i < 128 } {
			    # Constrained-media - Extension-media
			    $msg lappend CONTENTTYPE_PARAMS "Extension-Media [my parseTextString]"
			} else {
			    # Constrained-media Short Integer
			    $msg lappend CONTENTTYPE_PARAMS "type [my parseShortInteger]"
			}
		    } 
		    default {
			set noparams 1
		    }
		}
	    }
	    # content-type parsed, that means we have reached the end of the header
	    return 0
	}
	DATE {
	    # In seconds from 1970-01-01 00:00 GMT
	    $msg DATE [my parseLongInteger]
	}
	DELIVERY_REPORT {
	    # Yes | No
	    $msg DELIVERYREPORT $mmsYesNo([::util::atoi [string index $data [incr pos]]])
	}
	DELIVERY_TIME {
	    $msg DELIVERYTIME ""
	}
	EXPIRY {
	    # not sure if this is right, but if I remeber right, it's the same format as date...
	    $msg EXPIRY [my parseLongInteger]
	}
	FROM {
	    $msg FROM [my parseEncodedStringValue]
	    if { [::util::atoi [$msg FROM]] == [::util::atoi \x81] } {
		$msg FROM ""
	    }
	}
	MESSAGE_CLASS {
	    $msg MESSAGECLASS $mmsMessageClass([my parseMessageClassValue])
	}
	MESSAGE_ID {
	    # Text string
	    $msg MESSAGEID [my parseTextString]
	}
	MESSAGE_TYPE {
	    $msg MESSAGETYPE $mmsMessageTypes([::util::atoi [string index $data [incr pos]]])
	    
	    # check that the message type is m-send-req
	    if { [$msg MESSAGETYPE] ne {m-send-req} } {
		# Wrong type: The message-type field is not 'm-send-req' (Octet 128)
	    }
	}
	MMS_VERSION {

	    ## The version number (1.0) is encoded as a WSP short integer, which
	    ## is a 7 bit value. 
	    ## 
	    ## The three most significant bits (001) are used to encode a major
	    ## version number in the range 1-7. The four least significant
	    ## bits (0000) contain a minor version number in the range 1-14. 

	    $msg MMSVERSIONRAW [string index $data $pos]
	    $msg MMSVERSIONMAJOR [expr { ([::util::atoi [string index $data $pos]] & [::util::atoi \x70]) >> 4 }]
	    $msg MMSVERSIONMINOR [expr { ([::util::atoi [string index $data [incr pos]]] & [::util::atoi \x0F]) }]
	}
	MESSAGE_SIZE {
	    # Long integer
	    $msg MESSAGESIZE [my parseLongInteger]
	}
	PRIORITY {
	    # Low | Normal | High
	    $msg PRIORITY $mmsPriority([string index $data [incr pos]])
	}
	READ_REPLY {
	    # Yes | No
	    $msg READREPLY $mmsYesNo([::util::atoi [string index $data [incr pos]]])
	}
	REPORT_ALLOWED {
	    # Yes | No
	    $msg REPORTALLOWED $mmsYesNo([string index $data [incr pos]])
	}
	RESPONSE_STATUS {
	    $msg RESPONSESTATUS [string index $data [incr pos]]
	}
	RESPONSE_TEXT {
	    # Encoded string value
	    $msg RESPONSETEXT [my parseEncodedStringValue]
	}
	SENDER_VISIBILITY {
	    # Hide | show
	    $msg SENDERVISIBILITY $mmsYesNo([string index $data [incr pos]])
	}
	STATUS {
	    $msg STATUS [string index $data [incr pos]]
	}
	SUBJECT {
	    $msg SUBJECT [my parseEncodedStringValue]
	}
	TO {
	    $msg TO [my parseEncodedStringValue]
	}
	TRANSACTION_ID {
	    $msg TRANSACTIONID [my parseTextString]
	}
    }
    return true
}




## Function called after header has been parsed. This function fetches
## the different parts in the MMS. Returns true until it encounter end
## of data.
::messaging::mms::RequestHandler instproc parseParts {} {
    my instvar data pos msg 
    $msg instvar parts count
    set count [my parseUint]
    for {set i 0} {$i < $count} {incr i} {
	lappend parts [my parseMessagePart]
    }
    return false
}

::messaging::mms::RequestHandler instproc parseMessagePart {} {
    my instvar data pos

    # new part, so clear the old data and header
    set part_data ""
    set part_header ""
    set part_ctype ""
			


    # get header and data length
    incr pos
    set headerlen [my parseUint]
    incr pos
    set datalen [my parseUint]

    set ctypepos $pos
    set part_ctype [my parseContentType]
    # roll back position so it's just before the content-type again
    set pos $ctypepos

    # Read header. Actually, we don't do anything with this yet.. just skipping it (note that the content-type is included in the header)
    for {set j 0} {$j < $headerlen} {incr j} {
	append part_header [string index $data [incr pos]]
    }

    # read data
    for {set j 0} {$j < $datalen} {incr j} {
	append part_data [string index $data [incr pos]]
    }

    if { $datalen > 10000 } {
	set fp [open [acs_root_dir]/www/__tests/mms-test-image.jpg w]
	fconfigure $fp -translation binary
	puts -nonewline $fp $part_data
	close $fp
    }
    if { 0 } { error "datalen=$datalen,ctypepos=$ctypepos pos=$pos [string range $data $pos end], chr_i=[::util::atoi [string index $data $pos]]" }
    if { 0 } { error l=$headerlen,dl=$datalen,ct=$part_ctype,pos=$pos,ctypepos=$ctypepos,h=$part_header,[string length $data] }

    return [list ::messaging::mms::MessagePart -headerlen $headerlen -datalen $datalen -content_type $part_ctype -header $part_header -data part_data]	
}
	

## Parse message-class                                              ##
## message-class-value = Class-identifier | Token-text              ##
## Class-idetifier = Personal | Advertisement | Informational | Auto##

::messaging::mms::RequestHandler instproc parseMessageClassValue {} {
    my instvar data pos
    set chr_i [::util::atoi [string index $data [expr {1+$pos}]]]
    if { $chr_i > 127 } {
	# the byte is one of these 128=personal, 129=advertisement, 130=informational, 131=auto
	incr pos
	return $chr_i
    } else {
	return [my parseTextString]
    }
}
	

## Parse Text-string                                             ##
## text-string = [Quote <Octet 127>] text [End-string <Octet 00>]##

::messaging::mms::RequestHandler instproc parseTextString {} {
    my instvar data pos


    # Remove quote
    if { [::util::atoi [string index $data [expr {1+$pos}]]] == 127 } {
	incr pos
    }
    set str ""
    while { [::util::atoi [set ch [string index $data [incr pos]]]] } {
	append str $ch
    }
    return $str
}


## Parse Encoded-string-value                                            ##
##                                                                       ##
## Encoded-string-value = Text-string | Value-length Char-set Text-string##
##                                                                       ##

::messaging::mms::RequestHandler instproc parseEncodedStringValue {} {
    my instvar data pos
    set chr_i [::util::atoi [string index $data [expr {1+$pos}]]]
    if { $chr_i < 32 } {
	set len [my parseValueLength]
	for {set i 0} {$i < $len} {incr i} {
	    append str [string index $data [incr pos]]
	}
	return $str
    } else {
	return [my parseTextString]
    }
}
	
	

## Parse Value-length                                                            ##
## Value-length = Short-length<Octet 0-30> | Length-quote<Octet 31> Length<Uint> ##
##                                                                               ##
## A list of content-types of a MMS message can be found here:                   ##
## http://www.wapforum.org/wina/wsp-content-type.htm                             ##

::messaging::mms::RequestHandler instproc parseValueLength {} {
    my instvar data pos
    set chr_i [::util::atoi [string index $data [incr pos]]]
    if { $chr_i < 31 } {
	# it's a short-length
	return $chr_i
    } elseif { $chr_i == 31 } {
	# got the quote, length is an Uint
	incr pos
	return [my parseUint]
    } else {
	# uh, oh... houston, we got a problem
	error "Parse error: Short-length-octet $chr_i > 31 in Value-length at offset $pos"
    }
}

	
## Parse Long-integer                                                      ##
## Long-integer = Short-length<Octet 0-30> Multi-octet-integer<1*30 Octets>##

::messaging::mms::RequestHandler instproc parseLongInteger {} {
    my instvar data pos
    set longint 0
    # Get the number of octets which the long-integer is stored in
    set octetcount [::util::atoi [string index $data $pos]]
    incr pos
		
    # Error checking
    if { $octetcount > 30 } {
	error "Parse error: Short-length-octet $octetcount > 30 in Long-integer at offset [expr { $pos - 1 }]"
    }

    # Get the long-integer
    for {set i 0} {$i < $octetcount} {incr i} {
	set longint [expr { $longint << 8 }]
	incr longint [::util::atoi [string index $data [incr pos]]]
    }
		
    return $longint
}


## Parse Short-integer                                                   ##
## Short-integer = OCTET                                                 ##
## Integers in range 0-127 shall be encoded as a one octet value with the##
## most significant bit set to one, and the value in the remaining 7 bits##

::messaging::mms::RequestHandler instproc parseShortInteger {} {
    my instvar data pos
    set chr_i [::util::atoi [string index $data $pos]]
    return [expr { $chr_i & 127 }]
}


## Parse Integer-value                                        ##
## Integer-value = short-integer | long-integer               ##
##                                                            ##
## This function checks the value of the current byte and then##
## calls either parseLongInt() or parseShortInt() depending on##
## what value the current byte has                            ##

::messaging::mms::RequestHandler instproc parseIntegerValue {} {
    my instvar data pos
    set chr_i [::util::atoi [string index $data [incr pos]]]
    #error chr_i=$chr_i
    if { $chr_i < 31 } {
	return [my parseLongInteger]
    } elseif { $chr_i > 127 } {
	return [my parseShortInteger]
    } else {
	incr pos
	return 0
    }
}


## Parse Unsigned-integer                                          ##
##                                                                 ##
## The value is stored in the 7 last bits. If the first bit is set,##
## then the value continues into the next byte.                    ##
##                                                                 ##
## http://www.nowsms.com/discus/messages/12/522.html               ##

::messaging::mms::RequestHandler instproc parseUint {} {
    my instvar data pos
    set uint 0
    while { [::util::atoi [string index $data $pos]] & 128 } {
	# Shift the current value 7 steps
	set uint [expr { $uint << 7 }]
	# Remove the first bit of the byte and add it to the current value
	set uint [expr { $uint | ( [::util::atoi [string index $data $pos]] & 127 ) }]
	incr pos
    }

    # Shift the current value 7 steps
    set uint [expr { $uint << 7 }]

    # Remove the first bit of the byte and add it to the current value
    set uint [expr { $uint | ( [::util::atoi [string index $data $pos]] & 127 ) }]
    #if { $pos > 1 } { error uint=$uint}
    return $uint
}



::messaging::mms::RequestHandler instproc parseContentType {} {
    my instvar data pos
    [my info class] instvar mmsContentTypes

    set chr_i [::util::atoi [string index $data [expr {1+$pos}]]]
    if { $chr_i <= 31 } {
	# Content-general-form
	set len [my parseValueLength]
	
	# check if next byte is in range of 32-127. Then we have a Extension-media which is a textstring
	set next_chr_i [::util::atoi [string index $data [expr {1+$pos}]]]
	if { $next_chr_i > 31 && $next_chr_i < 128 } {
	    return [my parseTextString]
	} else {
	    #error int=[my parseIntegerValue]
	    # we have Well-known-media; which is an integer
	    set varName mmsContentTypes([my parseIntegerValue])
	    if { [info exists $varName] } {
		return [set $varName]
	    } else {
		return unknown-$varName
	    }
	}
    } elseif { $chr_i < 128 } {
	# Constrained-media - Extension-media
	return [my parseTextString]
    } else {
	# Constrained-media - Short Integer
	return $mmsContentTypes([my parseShortInteger])
    }		
}




## Send an OK response to the sender after the MMS has been recieved
## See "6.1.2. Send confirmation" in the wap-209-mmsencapsulation specification, on how this is constructed

::messaging::mms::RequestHandler instproc confirm {} {

    my instvar msg

    my instvar data pos

    append confirm \x8C ;# message-type
    append confirm \x81  ;# m-send-conf
    append confirm \x98 ;# transaction-id
    append confirm [$msg TRANSACTIONID]
    append confirm \x00 ;# end of string
    append confirm \x8D ;# version
    append confirm \x90 ;# 1.0
    append confirm \x92 ;# response-status
    append confirm \x80  ;# OK

    ns_log notice "Confirm [$msg TRANSACTIONID]"

    # respond with the m-send-conf
    return $confirm
}





set comment {
    /*---------------------------------------------------------------------*
    ## The MMS part class                                                 ##
    ## An instance of this class contains the one parts of an MMS message.##
    ##                                                                    ##
    ## The multipart type is formed as:                                   ##
    ## number |part1|part2|....|partN                                     ##
    ## where part# is formed by headerlen|datalen|contenttype|headers|data##
    ##---------------------------------------------------------------------*/
    class MMSPart {
	var $headerlen;
	var $header;
	var $DATALEN;
	var $CONTENTTYPE;
	var $DATA;
	
	/*----------------------------------*
	## Constructor, just store the data##
	##----------------------------------*/
	function MMSPart($headerlen, $datalen, $ctype, $header, $data) {
	    $this->hpos = 0;
	    $this->headerlen = $headerlen;
	    $this->DATALEN = $datalen;
	    $this->CONTENTTYPE = $ctype;
	    $this->DATA = $data;
	}
	
	/*-------------------------------------*
	## Save the data to a location on disk##
	##-------------------------------------*/
	function save($filename) {
	    $fp = fopen($filename, 'wb');
	    fwrite($fp, $this->DATA);
	    fclose($fp);
	}
    }
}