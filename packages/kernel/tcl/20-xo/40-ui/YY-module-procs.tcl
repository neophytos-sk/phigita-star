::xo::ui::Class ::xo::ui::ModuleFile -superclass {::xo::ui::Widget} -parameter {
    {module_file ""}
}

::xo::ui::ModuleFile instproc init {args} {
    my instvar module_file
    ns_log notice "module_file $module_file"

    if { [catch {
	::xo::ns::source $module_file
    } errmsg] } {
	ns_log notice "ModuleFile->init errmsg=$errmsg"
	rp_returnerror
	return
    }

    return [next]
}


::xo::ui::Class ::xo::ui::SourceFile -superclass {::xo::ui::Widget} -parameter {
    {source_file ""}
}

::xo::ui::SourceFile instproc render {visitor} {
    my instvar source_file
    uplevel \#0 ::xo::ns::source $source_file
    return [next]
}

