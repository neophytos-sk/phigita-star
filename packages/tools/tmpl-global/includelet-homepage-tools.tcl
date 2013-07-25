div -class pl {
    if { [string match *MSIE* [ns_set iget [ns_conn headers] User-Agent]] } {
	div -style "padding:10px;" {
	    t -disableOutputEscaping {
		<p id="hp" style="display:block; behavior:url(#default#homepage) url(#default#userData)"><a href="." onclick="kbs();">Make Us Your Homepage</a></p>
		<script>
		(function(){var b="hp",a=document.getElementById(b),c="http://www.phigita.net/",d;function k(){try{d=a.isHomePage(c)}catch(z){d=0}}k();if(!d)a.style.display="block";window.kbs=function(){try{a.setHomePage(c);k();(new Image).src="/kp?sa=X&ct=mgyhpb&cd="+!!d;}catch(z){}}})();
		</script>
	    }
	}
    }
    b { t "Tools: " }
    b {
	a -class fl -href "/spell-check/" -title [mc Spell_Check_Pitch "Verify the spelling of words. Ensure correct spelling."] {
	    t [mc Spell_Check "Spell Check"]
	}
    }
    set comment {
	b {
	    a -class "fl" -href "/currency-exchange/" -title [mc Currency_Exchange_Pitch "."] {
		t [mc Currency_Exchange "Currency Exchange"]
	    }
	}
	t " - "
    }
}