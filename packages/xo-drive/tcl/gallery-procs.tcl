ad_proc -public pa_get_exif_data {
    file
} {
    Returns a array get list with the some of the exif data
    or an empty string if the file is not a jpg file
     
    uses jhead
 
    Keys: Aperture Cameramake Cameramodel CCDWidth DateTime Exposurebias
    Exposuretime Filedate Filename Filesize Film Flashused Focallength
    Focallength35 FocusDist Jpegprocess MeteringMode Resolution
} {
    # a map from jhead string to internal tags.
    array set map [list {File date} Filedate \
                       {File name} Filename \
                       {File size} Filesize \
                       {Camera make} Cameramake \
                       {Camera model} Cameramodel \
                       {Date/Time} DateTime \
                       {Resolution} Resolution \
                       {Flash used} Flashused \
                       {Focal length} Focallength \
                       {Focal length35} Focallength35 \
                       {CCD Width} CCDWidth \
                       {Exposure time} Exposuretime \
                       {Aperture} Aperture \
                       {Focus Dist.} FocusDist \
                       {Exposure bias} Exposurebias \
                       {Metering Mode} MeteringMode \
                       {Jpeg process} Jpegprocess \
                       {Film} Film ]
 
    # try to get the data.
    if {[catch {set results [exec [acs_root_dir]/packages/gallery/bin/jhead $file]} errmsg]} {
        ns_log Warning "pa_get_exif_data: jhead failed with error - $errmsg"
        return {}
    } elseif {[string match {Not JPEG:*} $results]} {
        return {}
    }
 
    # parse data
    foreach line [split $results "\n"] {
        regexp {([^:]*):(.*)} $line match tag value
        set tag [string trim $tag]
        set value [string trim $value]
        if {[info exists map($tag)]} {
            set out($map($tag)) $value
        }
    }
                                                                                                                             
    # make sure we have a value for every tag
    foreach {dummy tag} [array get map] {
        if {![info exists out($tag)]} {
            set out($tag) {}
        }
    }
                                                                                                                             
    # fix the annoying ones...
    foreach tag [list  Exposuretime FocusDist] {
        if {[regexp {([0-9.]+)} $out($tag) match new]} {
            set out($tag) $new
        }
    }
                                                                                                                             
    foreach tag [list  DateTime Filedate] {
        regsub {([0-9]+):([0-9][0-9]):} $out($tag) "\\1-\\2-" out($tag)
    }
                                                                                                                             
    if {[regexp {.*35mm equivalent: ([0-9]+).*} $out(Focallength) match new]} {
        set out(Focallength35) $new
    } else {
        set out(Focallength35) {}
    }
    regsub {([0-9.]+)mm.*} $out(Focallength) "\\1" out(Focallength)
                                                                                                                             
    if {[string equal -nocase $out(Flashused) yes]} {
        set out(Flashused) 1
    } else {
        set out(Flashused) 0
    }
                                                                                                                             
    if {![empty_string_p $out(Cameramake)]} {
        set out(Film) Digital
    }

    regsub {([0-9]+).*} $out(Filesize) "\\1" out(Filesize)
                                                                                                                             
    return [array get out]
}
