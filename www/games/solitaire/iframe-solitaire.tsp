
    link -rel "stylesheet" -href "solitaire.css" -media "screen"
    script -type "text/javascript" {
	t -disableOutputEscaping {
	var cardBackgroundArray = new Array();
	cardBackgroundArray.push('images/card_bg1.gif');	
	cardBackgroundArray.push('images/card_bg2.gif');	
	}
    }	
    script -type "text/javascript" -src "solitaire.js"
    script -type "text/javascript" {
	t -disableOutputEscaping {
	    window.onload=initSolitaire;
	}
    }	
    button -onclick "resetGame();return false" {
	t "New game"
    }
	    div -id "bg_aces"
	    div -id "bg_seven"	
	    div -id "bg_deck" {
		div -id "bg_deck_inner"
		div -id "bg_deck_shown"
	    }

	    div -id "movingCardContainer"
