tmpl::master -title "Spell Check" -context_bar [ad_context_bar] -onload {onLoad()} {

    script -type "text/javascript" -src "spell-checker.js"
    script -type "text/javascript" {
	c {
	    var SC = null;
	    function onLoad() {
		SC = new SpellChecker();
		document.forms['wf'].q.focus();
		return false;
	    }
	}
    }

    div -style "float:left;width:450px;" {
	div -style "width:450px;padding:25px;margin:15px;background:ButtonFace;" {
	form -name wf -action word-suggest -type GET -onsubmit {return document.wf.q.value!='';} {
	    font -size "-1" {
		t "Enter a single word to spell check:"
		br
		input -name q -type text -size 25 -maxlength 80
		input -type submit -value "Check Word"
	    }
	}
	form -name tf -action text-suggest -type post {
	    font -size "-1" {
		t "Body of text to spell check: (Up to 20,000 characters)"
		br
		textarea -id textbody -name q -style "width:400px;height:300px;" -wrap soft -onkeyup {CountWords(document.tf.q.value)}
	    }
	    table {
		tbody {
		    tr {
			td -valign top {
			    font -size "-1" {
				t "Dictionary"
				select -id dictionary -name dictionary {
				    option -value el { t Greek }
				    option -value en { t English }
				}
				input -type "button" -value "Check Text" -onclick {SC.buttonPress('textbody');return false;}
				t " "
				input -type "button" -value "Clear" -onClick {document.tf.q.value='';CountWords(document.textbody.string.value)}

			    }
			}
			td -valign top {
			    font -size "-2" {
				t "Character Count: "
				font -id "charcount" {
				    t "0"
				}
				br
				t "Word Count: "
				font -id "wordcount" {
				    t "0"
				}
			    }
			}
		    }
		}
	    }
	}
}
	table -cellpadding 10 {
	    tr { 
		td {
		    div -style "margin:0;font-size:75%;width:200px;background:#f0f0f0;padding:4px;" {
			t "In computing terms, a spell checker is a software program designed to verify the spelling of words in a document, helping a user to ensure correct spelling."
			br
			a -href "http://en.wikipedia.org/wiki/Spell_checker" -style "color:green;" {
			    t "wikipedia: spell checker"
			}
		    }
		}

		td {
		    small {
			i { t "Supported Languages" }
			ul {
			    li {
				t "Greek" 
			    }
			    li {
				t "English"
			    }
			}
		    }
		}
	    }
	}
    }
    div -class little -style "padding:10px;margin-left:525px;border-left: 1px solid #efefef;" {
	::xo::google::adsense::slot 2239820321 160 600
    }

    script {
	c {
	    function CountWords(stext)
	    {
		var stemp;
		var scount=0;
		
		//Count
		for (var i = 0; i < stext.length; i++) 
		{
		 //If letter 0-9 or a-z or A-Z
		 if (((stext.charCodeAt(i) >= 0x30) && (stext.charCodeAt(i) <= 0x39)) || ((stext.charCodeAt(i) >= 0x41) && (stext.charCodeAt(i) <= 0x5A)) || ((stext.charCodeAt(i) >= 0x61) && (stext.charCodeAt(i) <= 0x7A)))
		 {
		     if (i==0)
		     {
			 scount++;
		     }
		     else
		     {
			 //If previous character is not a letter a-z or A-Z then count it
			 if (((stext.charCodeAt(i-1) < 0x30) || (stext.charCodeAt(i-1) > 0x39)) && ((stext.charCodeAt(i-1) < 0x41) || (stext.charCodeAt(i-1) > 0x5A)) && ((stext.charCodeAt(i-1) < 0x61) || (stext.charCodeAt(i-1) > 0x7A)))
			 {
			     scount++;
			 }
		     }
		 }
	     }
		
		text=document.getElementById('charcount').childNodes[0];
		text.nodeValue = stext.length;
		text=document.getElementById('wordcount').childNodes[0];
		text.nodeValue = scount;
		return scount
	    }
	}
    }

}