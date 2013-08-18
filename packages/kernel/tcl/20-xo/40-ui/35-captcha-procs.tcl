###package require Tclgd
package require tclgd

namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::CharacterRecognitionCaptcha -superclass {::xo::ui::Form.Field} -parameter {
    {label "captcha image, to tell computers and humans apart"}
    {info_text "Enter the string of characters appearing in the picture"}
    {width "231"}
    {height "72"}
    {maxrotation "30"}
    {noisefactor "9"}
    {noise_p "yes"}
    {grid_p "yes"}
    {wave_p "yes"}
    {fontpath "/web/data/fonts"}
    {captchapath "/web/data/captcha"}
    {name "captcha_input"}
    {allowBlank false}
    {TTF_RANGE {arial.ttf verdana.ttf georgia.ttf trebuc.ttf trebuc.ttf times.ttf comic.ttf impact.ttf andalemo.ttf courbd.ttf Dustismo.ttf PenguinAttack.ttf Domestic_Manners.ttf}}
} -instmixin add ::xo::ui::ControlTrait -jsClass Ext.form.TextField


::xo::ui::CharacterRecognitionCaptcha instproc changeTTF {} {
    my instvar TTF_RANGE
    my instvar fontpath

    return "${fontpath}/[lindex $TTF_RANGE [expr { int(rand()*[llength $TTF_RANGE]) }]]"
}


::xo::ui::CharacterRecognitionCaptcha instproc OLD-action(returnImage-S) {marshaller} {
    set imageTarget [my queryget -select [my domNodeId] -action returnImage imageTarget]
    if {[regexp {\.\.} $imageTarget]} {
	ns_return 200 text/html "ok"
    }
    set file [my captchapath]/${imageTarget}
    ad_returnfile_background 200 [ns_guesstype $file] $file
}

::xo::ui::CharacterRecognitionCaptcha instproc getConfig {} {

    my instvar domNodeId name

    set varList {
	allowBlank
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    lappend config "name:'$name'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}

::xo::ui::CharacterRecognitionCaptcha instproc isValid {} {
    set raw_value [my getRawValue]
    set captcha_hash [::xo::kit::queryget captcha_hash]
    set hash [my encrypt [split $raw_value ""]]
    ###ns_log notice "raw=[split $raw_value ""] hash=$hash captcha_hash=$captcha_hash"
    return [expr { $hash eq ${captcha_hash} }]
}

::xo::ui::CharacterRecognitionCaptcha instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode input img br

    my instvar domNodeId name

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    set captcha_token [my generateToken [my privateKey]]



    [next] appendFromScript {
	div -class x-form-element {
	    input -type hidden -name captcha_hash -value $captcha_token
	    #set uri [my uri -sign true -select $domNodeId -action returnImage [list imageTarget ${imageTarget}]]
	    set uri [my uri -sign true -select $domNodeId -action returnImagePNG [list captcha_token $captcha_token]]
	    img -src $uri -width [my width] -height [my height] -alt [my label]
	    set innerNode [input -id $domNodeId -type text -name $name -value "" -style "width:[my width]px;"]
	    br
	    t [my info_text]
	}
    }
    return $innerNode
}

::xo::ui::CharacterRecognitionCaptcha instproc encrypt {key} {
    set hash [ns_sha1 CaPtChA-[string toupper $key]]
    return $hash
}


::xo::ui::CharacterRecognitionCaptcha instproc getKeyFromToken {token} {
    set result ""
    if { [catch {
	set fp [open [my captchapath]/${token}.txt]
	set result [read ${fp}]
	close ${fp}
    } errmsg] } {
	ns_log notice "error reading captcha file, token=$token errmsg=$errmsg"
    }
    return $result
}

::xo::ui::CharacterRecognitionCaptcha instproc init_num_of_chars {} {
    my instvar lx ly width height minsize maxsize chars 

    set lx $width
    set ly $height

    set minsize 20
    set maxsize [expr {int($ly / 2.4)}]
    if { $maxsize < $minsize } {
	set minsize $maxsize
    }
    
    set chars [expr {int($lx / int(($maxsize + $minsize) / 1.5)) - 1}]
    return $chars
}

::xo::ui::CharacterRecognitionCaptcha instproc privateKey {} {
    my instvar __privateKey

    if {![info exists __privateKey]} {
	set chars [my init_num_of_chars]
	set __privateKey [my randomCode $chars]
    }

    return $__privateKey
}

::xo::ui::CharacterRecognitionCaptcha instproc randomCode {size} {
    set data [list 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N P Q R S T U V W X Y Z]
    set code ""
    for {set n 0} {$n < $size} {incr n} {
        lappend code "[lindex $data [expr {int(rand()*[llength $data])}]]"
    }
    return $code
}

::xo::ui::CharacterRecognitionCaptcha instproc generateImageOld {code} {
    set key $code
    set stamp [clock seconds]
    set hash [md5::md5 -hex $key]
    set target [acs_root_dir]/data/captcha/$hash-$stamp.png
    exec convert -antialias -size 150x50 null: -gravity center -pointsize 24 -fill \\#c0c0c0 -annotate 0 $code -blur 0 -wave 5x45 -swirl 15  png:$target
    return $target
}


::xo::ui::CharacterRecognitionCaptcha instproc randomColor {min max} {
    set r [expr {int([my randomNumber $min $max])}]
    set g [expr {int([my randomNumber $min $max])}]
    set b [expr {int([my randomNumber $min $max])}]
    return [list $r $g $b]
}

::xo::ui::CharacterRecognitionCaptcha instproc randomNumber {lower upper} {
    expr { (rand() * ($upper - $lower)) + $lower } 
}


::xo::ui::CharacterRecognitionCaptcha instproc generateToken {private_key} {
    set token [my encrypt $private_key]
    if { [catch {
	set fp [open [my captchapath]/${token}.txt w]
	puts $fp $private_key
	close $fp
    } errmsg] } {
	ns_log notice "failed writing captcha token file, token=$token private_key=$private_key errmsg=$errmsg"
    }
    return $token
}

::xo::ui::CharacterRecognitionCaptcha instproc action(returnImagePNG-S) {marshaller} {

    my init_num_of_chars
    set token [my queryget -select [my domNodeId] -action returnImagePNG captcha_token]
    set private_key [my getKeyFromToken $token]
    #ns_log notice "token=$token private_key=$private_key"

    my instvar width height minsize maxsize
    my instvar grid_p wave_p maxrotation
    my instvar noise_p noisefactor nb_noise

    set chars [string length $private_key]
    set nb_noise [expr {$noise_p ? ($chars * $noisefactor) : 0}]

    set pi 3.14159265

    set lx $width
    set ly $height


    set imgObj [GD create_truecolor "#auto" $width $height]
    set font [my changeTTF]
    foreach {r g b} [my randomColor 235 245] break
    set bgcolorObj   [$imgObj allocate_color $r $g $b]
    $imgObj filled_rectangle 0 0 $width $height $bgcolorObj 



    if {$wave_p} {

	### Generate Wave

	set stepWidth [expr {int($minsize/1.5)}]
	set stepHeight [expr {int($minsize/1.8)}]
	for {set i 0} {$i < $lx} {incr i $stepWidth} {
	    set direction 0
	    for {set j [expr {int([my randomNumber 0 $stepHeight])}]} {$j < $ly} {incr j $stepHeight} {
		if { [my randomNumber 0 3] > 2 } {
		foreach {r g b} [my randomColor 224 255] break
		    set colorObj [$imgObj allocate_color $r $g $b]
		    set cx [expr {$i+int($stepWidth/2)}]
		    set cy $j
		    set startAngle [expr {90+(180*$direction)}]
		    set endAngle [expr {270+(180*$direction)}]
		    $imgObj arc $cx $cy 5 $stepHeight $startAngle $endAngle $colorObj 
		    set direction [expr {!$direction}]
		}
	    }
	}
	for {set i 0} {$i < $ly} {incr i [expr {int($minsize/1.8)}]} {
	    set direction 0
	    for {set j [expr {int([my randomNumber 0 $stepWidth])}] } {$j < $lx} {incr j $stepWidth} {
		if { [my randomNumber 0 3] > 2 } {
		    foreach {r g b} [my randomColor 224 255] break
		    set colorObj [$imgObj allocate_color $r $g $b]
		    set cx $j
		    set cy [expr {$i+int($stepHeight/2)}]
		    set startAngle [expr {0+(180*$direction)}]
		    set endAngle [expr {180+(180*$direction)}]
		    $imgObj arc $cx $cy $stepWidth 5 $startAngle $endAngle $colorObj 
		    set direction [expr {!$direction}]
		}
	    }
	}
    }


    if {$grid_p} {

	### Generate Grid

	for {set i 0} {$i < $lx} {incr i [expr {int($minsize/1.5)}]} {
	    foreach {r g b} [my randomColor 0 127] break
	    set colorObj [$imgObj allocate_color $r $g $b]
	    $imgObj line $i 0 $i $ly $colorObj 
	}
	for {set i 0} {$i < $ly} {incr i [expr {int($minsize/1.8)}]} {
	    foreach {r g b} [my randomColor 160 224] break
	    set colorObj [$imgObj allocate_color $r $g $b]
	    $imgObj line 0 $i $lx $i $colorObj 
	}
    }

    if {$noise_p } {

	### Generate Noise

	for {set i 0} {$i < $nb_noise} {incr i} {
	    set size [expr int([my randomNumber [expr {int($minsize/2.3)}] [expr {int($maxsize/1.7)}]])]
	    set angle [expr {[my randomNumber -180 180]*(${pi}/180)}]
	    set x [expr {int([my randomNumber 0 $lx])}]
	    set y [expr {int([my randomNumber 0 $ly])}]
	    foreach {r g b} [my randomColor 160 224] break
	    set colorObj   [$imgObj allocate_color $r $g $b]
	    set text [format %c [expr {int([my randomNumber 45 250])}]]
	    $imgObj text $colorObj [my changeTTF] $size $angle $x $y $text
	}
    }


    ### Generate Text
    set x [expr {int([my randomNumber $minsize $maxsize])}]
    for {set i 0} {$i < $chars} {incr i} {
	set size [expr {int([my randomNumber $minsize $maxsize])}]
	set text [lindex $private_key $i]
	set angle [expr {[my randomNumber [expr {-1*$maxrotation}] $maxrotation]*(${pi}/180)}]
	set y [expr {int([my randomNumber [expr {int($size * 1.5)}] [expr {int($ly - ($size/7))}]])}]
	foreach {r g b} [my randomColor 0 127] break
	set colorObj   [$imgObj allocate_color $r $g $b]
	foreach {r g b} [my randomColor 0 127] {
	    incr r 127
	    incr g 127
	    incr b 127
	}
	set shadowObj [$imgObj allocate_color $r $g $b]
	set fontname [my changeTTF]
	$imgObj text $shadowObj $fontname $size $angle [expr {$x + int($size/15)}] $y $text
	$imgObj text $colorObj $fontname $size $angle $x [expr {$y - int($size/15)}] $text
	incr x [expr {int($size+($minsize/5))}]
    }



    ns_set put [ns_conn outputheaders] Expires [ns_httptime [ns_time]]

    #[clock clicks]
    #set imageTarget [my encrypt $private_key].png
    #$imgObj write_png [my captchapath]/$imageTarget
    set compression_level 6
    ns_respond -status 200 -type image/png -binary [$imgObj png_data $compression_level]
    ###$imgObj destroy
    rename $imgObj {}



    #return $imageTarget
}

