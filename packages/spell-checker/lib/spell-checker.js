
function SpellChecker() {
    var self = this;

    return {
	'buttonPress': function(id) {
	    SpellChecker['_textarea'] = id;
	    SpellChecker['_dictionary'] = 'dictionary';
	    SpellChecker.init = true;
	    SpellChecker.agt = navigator.userAgent.toLowerCase();
	    SpellChecker.is_ie = ((SpellChecker.agt.indexOf("msie") != -1) && (SpellChecker.agt.indexOf("opera") == -1));
	    
	    var uiurl = "spell-check-ui.html";
	    var win;
	    
	    if (SpellChecker.is_ie) {
		win = window.open(uiurl, "SC_spell_checker",
				  "toolbar=no,location=no,directories=no,status=no,menubar=no," +
				  "scrollbars=no,resizable=yes,width=600,height=450");
	    } else {
		win = window.open(uiurl, "SC_spell_checker",
				  "toolbar=no,menubar=no,personalbar=no,width=600,height=450," +
				  "scrollbars=no,resizable=yes");
	    }
	    win.focus();
	}
    };
}


SpellChecker['_stopEvent'] = function(ev) {
    if (SpellChecker.is_ie) {
        ev.cancelBubble = true;
        ev.returnValue = false;
    } else {
        ev.preventDefault();
        ev.stopPropagation();
    }
}



window['SpellChecker']=SpellChecker;

// this needs to be global, it's accessed from spell-check-ui.html
SpellChecker['editor'] = null;

