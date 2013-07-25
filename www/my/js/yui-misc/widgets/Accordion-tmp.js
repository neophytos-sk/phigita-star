function Accordion(id)
{
	this.container = document.getElementById(id);
	this.container.style.overflow = "hidden";
	this.horizontal = (YAHOO.util.Dom.getElementsByClassName("HorizontalAccordionItem", "div", this.container).length != 0);
	this.animating = false;
	this.items = YAHOO.util.Dom.getElementsByClassName("AccordionItem", "div", this.container);
	for (var i = 0; i < this.items.length; i++)
	{
		this.items[i].parent = this;
		this.items[i].header = YAHOO.util.Dom.getElementsByClassName("AccordionHeader", "div", this.items[i])[0];
		this.items[i].body = YAHOO.util.Dom.getElementsByClassName("AccordionBody", "div", this.items[i])[0];
		this.items[i].body.style.overflow = "auto";
		var active = (this.horizontal) ? (this.items[i].body.offsetWidth > 0) : (this.items[i].body.offsetHeight > 0)
		if (active)
		{
			this.activeItem = this.items[i];
			if (this.horizontal)
			{
				var w = this.container.offsetWidth - (this.items[i].header.offsetWidth * 3) - 2;
				this.activeItem.body.style.width = w + "px";
				this.shrinkAtts = {width:{from:w, to:0}};
				this.expandAtts = {width:{from:0, to:w}};
			}
			else
			{
				var h = this.activeItem.body.offsetHeight;
				this.activeItem.body.style.height = h + "px";
				this.shrinkAtts = {height:{from:h, to:0}};
				this.expandAtts = {height:{from:0, to:h}};
			}
		}

//		Make the header text vertical
		if (this.horizontal)
		{
			var headerChar = this.items[i].header.innerHTML.split("");
			while (this.items[i].header.firstChild)
				this.items[i].header.removeChild(this.items[i].header.firstChild);
			for (var j = 0; j < headerChar.length; j++)
			{
				var c = headerChar[j];
				if (c == " ")
					this.items[i].header.appendChild(document.createElement("br"));
				else
				{
					this.items[i].header.appendChild(document.createTextNode(c));
					this.items[i].header.appendChild(document.createElement("br"));
				}
			}
		}

		YAHOO.util.Event.addListener(this.items[i].header, "click", function()
		{
//			Clicked on the header of the active item
			if (this.parent.activeItem == this)
				return;

//			Don't respond if we're already in a transition
			if (!this.parent.animating)
			{
				this.parent.animating = true;
				var shrink = new YAHOO.util.Anim(this.parent.activeItem.body, this.parent.shrinkAtts, 0.5, YAHOO.util.Easing.easeNone);
				var expand = new YAHOO.util.Anim(this.body, this.parent.expandAtts, 0.5, YAHOO.util.Easing.easeNone);
				expand.onComplete.subscribe(function()
				{
					this.parent.activeItem = this;
					this.parent.animating = false;
				}, this, true);
				shrink.animate(), expand.animate();
			}
		}, this.items[i], true);
	}      
};
