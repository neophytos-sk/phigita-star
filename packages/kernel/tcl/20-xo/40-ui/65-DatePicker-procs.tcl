::xo::ui::Class ::xo::ui::DatePicker -superclass {::xo::ui::Widget} -parameter {
    {cancelText ""}
    {dayNames ""}
    {disabledDates ""}
    {disabledDatesRE ""}
    {disabledDatesText ""}
    {format ""}
    {maxDate ""}
    {maxText ""}
    {minDate ""}
    {minText ""}
    {monthNames ""}
    {monthYearText ""}
    {nextText ""}
    {okText ""}
    {prevText ""}
    {showToday ""}
    {startDay ""}
    {todayText ""}
    {todayTip ""}
    {style ""}
} -jsClass Ext.DatePicker

::xo::ui::DatePicker instproc getConfig {} {

    my instvar domNodeId

    set varList {
	cancelText
	dayNames
	disabledDates
	disabledDatesRE
	disabledDatesText
	format
	maxDate
	maxText
	minDate
	minText
	monthNames
	monthYearText
	nextText
	okText
	prevText
	showToday
	startDay
	todayText
	todayTip
	style
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
        if { [my set $varName] ne {} } {
            lappend config "${varName}:[my set $varName]"
        }
    }

    return \{[join $config {,}]\}

}


::xo::ui::DatePicker instproc render {visitor} {
    my instvar domNodeId

    $visitor ensureNodeCmd elementNode div
    $visitor ensureLoaded XO.Fx XO.DatePicker

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    $node setAttribute class x-hidden
    return $node

}
