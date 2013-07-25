	if(cardBackgroundArray.length==0)cardBackgroundArray.push('images/card_bg1.gif');
	var cardTypes = ['s','d','h','c'];
	var cardColors = {'s':0,'d':1,'h':1,'c':0};
	var cardObjectArray = new Array();
	var cardCounter  = 0;
	var cardMoveTarget = false;
	var sevenStackArray = new Array();
	var acesStackArray = new Array();
	
	function sortCards(a,b){
		return Math.random() - Math.random();	
	}
	
	function revealCard(divObj)
	{
		var imgs = divObj.getElementsByTagName('IMG');
		imgs[1].style.display='none';
		
	}
	
	function coverCard(divObj)
	{
		var imgs = divObj.getElementsByTagName('IMG');
		imgs[1].style.display='';		
	}
	
	function dealCards()
	{
		var cardCounter = 0;
		for(var no=0;no<7;no++){
			for(var no2=no;no2<7;no2++){
				var obj = document.getElementById('bg_seven_card'+no2);
				var subs = obj.getElementsByTagName('DIV');
				if(subs.length==0){
					obj.appendChild(cardObjectArray[cardCounter]);
					cardObjectArray[cardCounter].style.top = '0px';
				}else{
					subs[subs.length-1].appendChild(cardObjectArray[cardCounter]);	
					cardObjectArray[cardCounter].style.top = verticalSpaceBetweenCards + 'px';
				}
				
				if(no2==no)revealCard(cardObjectArray[cardCounter]);
				cardCounter++;
			}			
		}		
	}
	
	function getAvailableEndStack(initID)
	{
		var numericID = initID.replace(/[^\d]/g,'');
		if(numericID==1){
			for(var no=0;no<4;no++){
				var obj = document.getElementById('bgEnd' + no);
				var subObj = obj.getElementsByTagName('DIV');
				if(subObj.length==0)return obj;	
			}		
		}else{
			var type = initID.substr(0,1);
			for(var no=0;no<4;no++){
				var obj = document.getElementById('bgEnd' + no);
				var subObj = obj.getElementsByTagName('DIV');
				if(subObj.length>0){
					if(subObj[subObj.length-1].id == type + (numericID-1))return obj;		
				}				
			}			
		}
		
		return false;
	}
	
	
	function finishCard()
	{
		var dest = getAvailableEndStack(this.parentNode.id);
		var subDivs = this.parentNode.getElementsByTagName('DIV');
		if(subDivs.length>0)return;
		if(this.parentNode.parentNode.id=='bg_deck_shown'){
			var parent = this.parentNode.parentNode;
			var subDivs = parent.getElementsByTagName('DIV');
			if(this.parentNode!=subDivs[subDivs.length-1])return;	
			
		}
		
	
		
		if(dest){
			this.parentNode.style.top = '0px';
			this.parentNode.style.left = '0px';
			dest.appendChild(this.parentNode);
		}
		var gameFinished = true;
		for(var no=0;no<acesStackArray.length;no++){
			var tmpDivs = acesStackArray[no].getElementsByTagName('DIV');
			if(tmpDivs.length<13)return;			
		}		
		alert("Congratulations! - you did it.\nThank you for trying this game at www.dhtmlgoodies.com");
	}
	
	function getTopDiv(inputDiv){
		while(inputDiv.parentNode && inputDiv.tagName!='BODY'){			
			if(inputDiv.id.indexOf('bg_')>=0)return inputDiv;
			inputDiv = inputDiv.parentNode;
		}		
		return inputDiv;
	}
	
	function initRevealCard()
	{
		var parentObj = getTopDiv(this);
		if(parentObj.id.indexOf('bg_seven_card')>=0){	// This card is on the "board" of seven cards
			var subDivs = parentObj.getElementsByTagName('DIV');
			if(this.parentNode==subDivs[subDivs.length-1]){
				revealCard(this.parentNode);		
			}		
		}		
		if(parentObj.id=='bg_deck_inner'){
			var subDivs = parentObj.getElementsByTagName('DIV');
			var maxIndex = subDivs.length-1;
			var minIndex = Math.max(-1,maxIndex-3);			
			if(subDivs.length>0){
				var divsShown = document.getElementById('bg_deck_shown').getElementsByTagName('DIV');
				for(var no=0;no<divsShown.length;no++){
					divsShown[no].style.left='0px';
				}					
			}			
			for(var no=maxIndex;no>minIndex;no--){
				revealCard(subDivs[no]);
				subDivs[no].style.left = (maxIndex-no) * 10 + 'px'; 
				document.getElementById('bg_deck_shown').appendChild(subDivs[no]);
			}
			
			
			
		}	
	}
	
	function restartDeck()
	{
		if(this.id=='bg_deck_inner'){
			var parentObj = document.getElementById('bg_deck_shown');
		}else{
			var parentObj = getTopDiv(this);
		}
		if(parentObj.id=='bg_deck_shown'){
			var destObj = document.getElementById('bg_deck_inner');
			var subDivs = destObj.getElementsByTagName('DIV');
			if(subDivs.length==0){
				var movingCards = parentObj.getElementsByTagName('DIV');	
				for(var no=movingCards.length-1;no>=0;no--){
					coverCard(movingCards[no]);		
					movingCards[no].style.left = '0px';			
					destObj.appendChild(movingCards[no]);
				}
			}			
		}
	}
	
	function cancelEvent()
	{
		return false;
	}
	
	function resetGame()
	{
		cardObjectArray = cardObjectArray.sort(sortCards);
		var bgDeck = document.getElementById('bg_deck_inner');
		for(var no=0;no<cardObjectArray.length;no++){

			cardObjectArray[no].style.top = '0px';
			coverCard(cardObjectArray[no]);		
			cardObjectArray[no].style.left = '0px';
			bgDeck.appendChild(cardObjectArray[no]);
		}		
		
		dealCards();
		
	}
	
	var cardMove_initMouseX;
	var cardMove_initMouseY;
	
	var cardInitX;
	var cardInitY;
	
	var cardMoveCounter = -1;
	var cardToMove = false;
	
	var verticalSpaceBetweenCards = 15;
	
	function getTopPos(inputObj)
	{
		
	  var returnValue = inputObj.offsetTop;
	  while((inputObj = inputObj.offsetParent) != null){
	  	returnValue += inputObj.offsetTop;
	  }
	  return returnValue;
	}
	
	function getleftPos(inputObj)
	{
	  var returnValue = inputObj.offsetLeft;
	  while((inputObj = inputObj.offsetParent) != null)returnValue += inputObj.offsetLeft;
	  return returnValue;
	}
	
	function initCardMove(e)
	{
		if(document.all)e = event;
		cardMoveTarget = this.parentNode.parentNode;
		if(cardMoveTarget.id=='bg_deck_shown'){
			var subDivs = cardMoveTarget.getElementsByTagName('DIV');
			if(subDivs[subDivs.length-1]!=this.parentNode)return;		
		}
		cardToMove = this.parentNode;
		cardMoveCounter = 0;
		cardMove_initMouseX = e.clientX;
		cardMove_initMouseY = e.clientY;
		
		cardInitX = getleftPos(this.parentNode.parentNode);
		cardInitY = getTopPos(this.parentNode.parentNode);
				
		startCardMove();
		
		return false;
	}
	
	function startCardMove()
	{
		if(cardMoveCounter>=0 && cardMoveCounter<10){
			cardMoveCounter = cardMoveCounter + 1;
			setTimeout('startCardMove()',10);
		}
		if(cardMoveCounter>=10){
			//cardToMove.style.left = '0px';
			document.getElementById('movingCardContainer').style.left= cardInitX +'px';
			document.getElementById('movingCardContainer').style.top= cardInitY/1 + 5 +'px';
			document.getElementById('movingCardContainer').appendChild(cardToMove);
		}		
	}
	
	function cardMove(e)
	{
		if(cardMoveCounter>=10){
		if(document.all)e = event;
			document.getElementById('movingCardContainer').style.left = e.clientX - cardMove_initMouseX + cardInitX/1 + 'px' ;
			document.getElementById('movingCardContainer').style.top = e.clientY/1 - cardMove_initMouseY/1 + cardInitY/1 + 'px';
		}
	}
	
	function stopMoveCard(e)
	{
		if(cardMoveCounter==-1)return;
		cardMoveCounter = -1;
		if(document.all)e = event;
		var divs = document.getElementById('movingCardContainer').getElementsByTagName('DIV');
		if(divs.length==0)return;
		var moveObj = document.getElementById('movingCardContainer');
		var leftPos = moveObj.style.left.replace('px','')/1;
		var topPos = moveObj.style.top.replace('px','')/1;	
		
		for(var no=0;no<sevenStackArray.length;no++){
			var tmpLeft = getleftPos(sevenStackArray[no]);
			var tmpTop = getTopPos(sevenStackArray[no]);			
			var subDivs = sevenStackArray[no].getElementsByTagName('DIV').length;
			if(leftPos>=tmpLeft-70 && leftPos<=tmpLeft+70 && topPos>=tmpTop-100 && topPos<=(tmpTop+100 + (subDivs*10))){
				var topDivTarget = getTopDiv(cardMoveTarget);
				if(topDivTarget!=sevenStackArray[no]){
					var tmpDivs = sevenStackArray[no].getElementsByTagName('DIV');					
					var cardTypeThis = divs[0].id.substr(0,1);
					var numericIDThis = divs[0].id.replace(/[^\d]/g,'');					
					if(tmpDivs.length==0){
						if(numericIDThis==13){
							divs[0].style.left = '0px';
							divs[0].style.top = '0px';
							sevenStackArray[no].appendChild(divs[0]);
							return; 
						}						
					}else{						
						var destDiv = tmpDivs[tmpDivs.length-1];						
						var cardTypeDest = destDiv.id.substr(0,1);						
						var numericIDDest = destDiv.id.replace(/[^\d]/g,'');						
						if(cardColors[cardTypeDest]!=cardColors[cardTypeThis] && numericIDDest-1==numericIDThis){
							divs[0].style.top = verticalSpaceBetweenCards + 'px';
							divs[0].style.left = '0px';
							destDiv.appendChild(divs[0]);
							return; 
						}
					}
				}	
			}			
		}
		
		var gameFinished = true;
		for(var no=0;no<acesStackArray.length;no++){
			var tmpLeft = getleftPos(acesStackArray[no]);
			var tmpTop = getTopPos(acesStackArray[no]);			
			var tmpDivs = acesStackArray[no].getElementsByTagName('DIV');			
			
			if(leftPos>=tmpLeft-70 && leftPos<=tmpLeft+70 && topPos>=tmpTop-100 && topPos<=tmpTop+100){
				var topDivTarget = getTopDiv(cardMoveTarget);
				if(topDivTarget!=acesStackArray[no]){
					var cardTypeThis = divs[0].id.substr(0,1);
					var numericIDThis = divs[0].id.replace(/[^\d]/g,'');
					if(tmpDivs.length==0){
						if(numericIDThis==1){
							divs[0].style.left = '0px'
							divs[0].style.top = '0px' 
							acesStackArray[no].appendChild(divs[0]);
							return; 
						}
						
					}else{
						var destDiv = tmpDivs[tmpDivs.length-1];						
						var cardTypeDest = destDiv.id.substr(0,1);						
						var numericIDDest = destDiv.id.replace(/[^\d]/g,'');						
						if(cardTypeDest==cardTypeThis && numericIDDest==(numericIDThis-1)){
							divs[0].style.left = '0px';
							divs[0].style.top = '0px';
							destDiv.appendChild(divs[0]);
							return; 
						}
					}   
				}	
			}

			if(tmpDivs.length<13)gameFinished=false;						
			
		}
		
		if(gameFinished){
			alert("Congratulations! - you did it.\nThank you for trying this game at www.dhtmlgoodies.com");
		}
		
		
		if(divs.length>0){
			if(cardMoveTarget.id!='bg_deck_shown')divs[0].style.left = '0px';
			cardMoveTarget.appendChild(divs[0]);			
		}
	}
	
	
	
	function initSolitaire()
	{
		var imageArray = new Array();
		var bgImageNo = Math.floor(Math.random()*cardBackgroundArray.length);

		for(var no=0;no<cardTypes.length;no++){
			imageArray[no] = new Array();
			
			for(var no2=1;no2<=13;no2++){
				imageArray[no][no2] = new Image();
				imageArray[no][no2].src = 'images/bg_' + cardTypes[no] + no2 + '.gif';
				
				var div = document.createElement('DIV');
				div.id = cardTypes[no] + no2;
				div.className='card';
				div.style.left = '0px';
				var img = document.createElement('IMG');
				img.src = imageArray[no][no2].src;
				img.style.position = 'absolute';
				img.style.top = '0px';
				img.style.paddingLeft = '1px';
				img.style.paddingRight = '2px';
				img.style.paddingTop = '5px';
				img.style.paddingBottom = '1px';
				img.style.backgroundColor='#FFF';
				img.onselectstart = cancelEvent;
				img.ondragstart = cancelEvent;
				img.ondblclick = finishCard;
				img.style.border = '1px solid #000000';
			
				img.onmousedown = initCardMove;
				
				var coverImage = document.createElement('IMG');
				
				coverImage.src = cardBackgroundArray[bgImageNo];
				coverImage.style.position = 'absolute';
				//coverImage.style.zIndex = '2';				
				coverImage.onselectstart = cancelEvent;
				coverImage.ondragstart = cancelEvent;
				coverImage.onclick = initRevealCard;
				coverImage.style.border = '1px solid #000000';			
				coverImage.style.paddingLeft = '0px';
				coverImage.style.paddingRight = '0px';
				coverImage.style.backgroundColor='#CCC';
				div.appendChild(img);
				div.appendChild(coverImage);				
				cardObjectArray.push(div);				
				cardCounter++;
			}	
		}	

		document.body.onmousemove = cardMove;
		document.body.onmouseup = stopMoveCard;
		
		var bg_aces = document.getElementById('bg_aces');
		for(var no=0;no<4;no++){
			var div = document.createElement('DIV');
			div.style.width = '72px';
			div.style.position = 'absolute';
			div.style.top = '20px';
			div.style.left = 20 + (no*110) + 'px';
			div.style.height = '100px';
			/* div.style.backgroundImage = 'url(\'images/stack_bg1.gif\')'; */
			div.style.backgroundRepeat = 'no-repeat';
			div.style.border='1px dotted #CCC';
			div.id = 'bgEnd' + no;			
			bg_aces.appendChild(div);	
			acesStackArray.push(div);	
		}
		
		var bg_seven = document.getElementById('bg_seven');
		for(var no=0;no<7;no++){
			var div = document.createElement('DIV');
			div.style.width = '130px';
			div.style.position = 'absolute';
			div.style.top = '20px';
			div.id = 'bg_seven_card'+no;
			div.style.left = 20 + (no*105) + 'px';
			div.style.height = '120px';
			//div.style.backgroundImage = 'url(\'images/stack_bg1.gif\')';
			div.style.backgroundRepeat = 'no-repeat';
			bg_seven.appendChild(div);	
			sevenStackArray.push(div);
						
		}	
		
		document.getElementById('bg_deck_inner').onclick = restartDeck;
		
		resetGame();
		
			 
	}