tmpl::blank {
    ul {
	li { a -href "finance/" { t "Finance" } }
	li { a -href "critbit/" { t "Data Structures: cribit" } }
	li { a -href "liblinear/" { t "LIBLINEAR" } }
	li { a -href "math/" { t "Math" }
	    ul {
		li { 
		    t "Binomial Coefficient: " 
		    form -action math/binomial-coefficient {
			t "n = "; input -name n -size 5
			nt "&nbsp;"
			t "k = "; input -name k -size 5
			input -type submit -value "Calculate"
		    }
		}
	    }
	}
	li { a -href "cpp/" { t "C++" } 
	    ul {
		li { a -href "cpp/virtual/" { t "Virtual Functions" } 
		    ul {
			li { a -href "cpp/virtual/virtual-test-1" { t "virtual test 1" } }
		    }
		}
	    }
	}
	li { t "HTTP"
	    ul {
		li { a -href "http/http-headers" { t "http headers" } }
	    }
	}
	li { t "Structured Text"
	    ul {
		li { a -href "structured_text/" { t "Parse sample7.stx" } }
	    }
	}

	li { t "Developer" 
	    ul {
		li { 
		    a -href "TclEval/" { t "TclEval" } 
		}
	    }
	}
    }
}