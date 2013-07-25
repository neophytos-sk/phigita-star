proc mail_decode_body { mailid msgid bodydata { bodyid "" } } {


    array set struct $bodydata

    

    if { $struct(type) == "multipart" } {
      set body ""
      set files ""
	for { set i 1 } { $i <= $struct(part.count) } { incr i } {
	    array unset part
	    array set part $struct(part.$i)

	    if {[string equal [string tolower $struct(subtype)] alternative] && [string equal [string tolower $part(subtype)] "html"]} continue;

	    if { $bodyid != "" } { set partid "$bodyid.$i" } else { set partid $i }
	    if { $part(type) == "multipart" } {
		append body [mail_decode_body $mailid $msgid $struct(part.$i) $partid]
		continue
	    }
	    if { [info exists part(body.name)] } {
		append files {<TR><TD>[ossweb::file::link webmail $part(body.name) -html "TARGET=file" mailid $mailid msgid $msgid partid $partid]</TD>
		    <TD>[string tolower "$part(type)/$part(subtype)"]</TD>
		    <TD>[ossweb::util::size [ossweb::util::coalesce part(bytes)]]</TD>
		    </TR>}
	    } else {
		append body [mail_format_body [::encoding convertfrom [::mime::reversemapencoding $part(body.charset)] [ns_imap body $mailid $msgid $partid -decode -flags UID]] $part(subtype)]
	    }
	    append body "<P>"
	}
	if { $files != "" } {
        append body "<TABLE WIDTH=100% BORDER=0><TR CLASS=osswebFirstRow><TD COLSPAN=3><B>Attachments</B></TD></TR>" $files "</TABLE>"
	}
    } else {
	if { $bodyid != "" } { set partid "$bodyid.1" } else { set partid 1 }
	set body [mail_format_body [::encoding convertfrom [::mime::reversemapencoding $struct(body.charset)] [ns_imap body $mailid $msgid $partid -decode -flags UID]] $struct(subtype)]
    }
    return $body
}

# Formats body text according to given type, used for putting
# email body into display form, takes care about all dangerous tags/symbols
proc mail_format_body { body type } {

    switch $type {
	HTML {
	    set body [ns_imap striphtml $body]
	}
	default {
	    #do nothing
	}
    }
    return $body
}



ad_page_contract {
	@author Neophytos Demetriou
} {
	id:integer
}


set mailid [ns_imap open -mailbox {{localhost/ssl/novalidate-cert}} -user k2pts -password 662051]

tmpl::master -title "One Message" -context_bar [ad_context_bar "One Message"] {

        ns_imap struct $mailid $id -array struct -flags UID
	ns_imap headers ${mailid} ${id} -array headers -flags UID
	set body [mail_decode_body $mailid $id [array get struct]]

	t [array get struct]
	pre {
	    foreach {name value} [array get headers] {
		t "${name}: "
		t ${value}
		br
	    }
	}
	p
	table -bgcolor "\#efefef" -width "100%" {
	    foreach name {SUBJECT DATE FROM TO REPLY-TO CC} pretty_print {Subject Date From To Reply-To CC} {
		tr {
		    td -align right -nowrap "" {
			b {t ${pretty_print}: }
		    }
		    td -width 100% {
			if {[info exists headers(${name})]} {
			    t [mime::field_decode $headers(${name})]
			}
		    }
		}
	    }
	}
	p

	pre -wrap "" {
	    t $body
	}
	p
	hr


	if { $struct(type) == "multipart" } {
          for { set i 1 } { $i <= $struct(part.count) } { incr i } {
	      array unset part
	      array set part $struct(part.$i)
	      array set bodystruct [ns_imap bodystruct $mailid $id $i -flags UID]



	      if {![info exists part(body.charset)]} {
		  set part(body.charset) utf-8
	      }

	      hr -width 80% -size 4
	      b { t "Part ${i}" }
	      br



	      t [array get part]
	      br
	      pre { t [array get bodystruct] }
	      br
	      pre -style {font-family:"Arial Unicode MS",Arial; word-wrap:break-word;} {
		  if { ![info exists part(body.name)] } {

		      set body [ns_imap body $mailid $id $i -flags UID]
		      if {[string equal [string tolower $part(encoding)] base64]} {
			  set body [base64::decode ${body}]
		      } elseif {[string equal [string tolower $part(encoding)] qprint]} {
			  set body [ns_imap decode qprint ${body}]
		      }
		      t "XXXX.$i $part(encoding)"
		      p
		      t [::encoding convertfrom [::mime::reversemapencoding $part(body.charset)] ${body}]

		  } else {
		      a -href "attachment/$part(body.name)?id=${id}&part=${i}" {
			  t $part(body.name)
		      }
		      br
		      if { [string equal $bodystruct(type) message] } {
			  t "---------- Forwarded message ----------\n"
			  t [ns_imap body $mailid $id $i -decode]
		      }
		  }
	      }
	  }
	} else {
	    t [array get struct]
	    p
	    if {![info exists struct(body.charset)] } {
		set struct(body.charset) iso-8859-1
	    }
	    set body [ns_imap text ${mailid} ${id} -flags UID]
	    if {[info exists struct(encoding)]} {
		if {[string equal [string tolower $struct(encoding)] base64]} {
		    set body [base64::decode ${body}]
		}
	    }
	    pre { t [::encoding convertfrom [::mime::reversemapencoding $struct(body.charset)] ${body}] }
	}
    }



ns_imap close $mailid


