namespace eval g11n {;}
namespace eval g11n::conn {;}

proc g11n::gettext { src_string } {

    #use [ad_conn language] to get the language preference

#    return \#$src_string\#
    return $src_string

}


# convert message
proc g11n::mc {src args} {
}


# register message
proc g11n::mr {} {
}
