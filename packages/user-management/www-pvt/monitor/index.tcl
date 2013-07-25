#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/20-template-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/27-style-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/28-script-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/28-js-fun-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/29-hypertext-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/34-dataview-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/36-dragdrop-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/41-viewport-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/70-tab-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/75-toolbar-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/80-menu-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/90-tree-procs.tcl


namespace eval ::xo {;}
namespace eval ::xo::ui {;}





namespace eval ::xo::ui {

    Page new -appendFromScript {

	JS.Function showWindowFn -body {}
	JS.Function removeFeedFn -map {tree0} -body {
	    var s = tree0.getSelectionModel().getSelectedNode();
	    if(s) {
		tree0.removeFeed(s.attributes.url);
	    }
	}

	Toolbar tb0 -appendFromScript {

	    Toolbar.Button new \
		-text "'Add Feed'" \
		-iconCls "'add-feed'" \
		-map {showWindowFn} \
		-handler showWindowFn

	    Toolbar.Button new \
		-text "'Remove'" \
		-iconCls "'delete-icon'" \
		-map {removeFeedFn} \
		-handler removeFeedFn

	}



	Viewport new -layout border -appendFromScript {
	    Panel new -html 'hello' -title 'hello' -split true -border true -bodyBorder true -region north -height 40

	    TreePanel tree0 -map {tb0} -tbar tb0 -rootVisible true -autoScroll true -lines false -enableDrop true -appendFromScript {
		TreeNode new -expanded true -text "'My Feeds'" -cls "'feeds-node'" -appendFromScript {
		    TreeNode new -text "'Buzz'"
		}
	    } -region 'west' -width 225 -minSize 175 -maxSize 400 -title 'Feeds' -collapsible true -margins "'5 0 5 5'" -cmargins "'5 5 5 5'" -collapseFirst false

	    TabPanel new -appendFromScript {
		Panel new -html 'hello' -width 200 -height 200 -title 'hello' -split true -border true -bodyBorder true
		Panel new -html 'world' -width 200 -height 200 -title 'hello' -split true -border true -bodyBorder true
	    } -region center
	}
    }
}