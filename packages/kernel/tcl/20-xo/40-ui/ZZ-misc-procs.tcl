namespace eval ::xo {;}
namespace eval ::xo::ui {;}


Class ::xo::ui::VerticalPanel -superclass {::xo::ui::Widget}
::xo::ui::VerticalPanel instproc accept {{-rel default} {-action "visit"} visitor} {
    set instmixins [Object info instmixin -guards]
    set o [self]
    Object instmixin add [subst -nobackslashes -nocommands {::xo::ui::VerticalPanelItem -guard {[my parentNode] eq {$o} }}]
    set node [next]
    Object instmixin $instmixins
    return $node
}
::xo::ui::VerticalPanel instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode div
    div { set innerNode [next] }
    return $innerNode
}

Class ::xo::ui::VerticalPanelItem -superclass {::xo::ui::Widget}
::xo::ui::VerticalPanelItem instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode div
    set node [div { next }]
    return $node
}
