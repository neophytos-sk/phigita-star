source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/20-template-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/28-script-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/28-js-fun-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/29-hypertext-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/34-dataview-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/41-viewport-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/70-tab-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/75-toolbar-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/80-menu-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/90-tree-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/95-desktop-procs.tcl


namespace eval ::xo::ui {

    Page new -appendFromScript {

	Desktop new

	ScriptFile new -need "XO.Panel XO.Button XO.Menu.Extra XO.DD" -scriptFile [acs_root_dir]/www/lib/xo-1.0.0/source/desktop/sample.js

    }
}