
	//img.setAttribute('style','background-image:url('+data.url+')');
	//a.setAttribute('style',"border: 0pt none ; padding: 0px; -moz-user-select: none; cursor: move; position: relative;");
	//a.setAttribute('href',data.url);
	//span.setAttribute('style','border: 0pt none ; padding: 0pt; overflow: visible; -moz-user-select: none; cursor: auto; text-indent: 0pt; width: 140px; height: 41px;');

	//img.setAttribute('style',"border: 0pt none ; padding: 0px; -moz-user-select: none; cursor: move; position: relative;");

        //div.setAttribute('style',"padding: 0px; background: rgb(0, 0, 0) none repeat scroll 0%; overflow: hidden; position: absolute; top: -30px; left: 0px; display: none; z-index: 10; cursor: auto; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial; opacity: 0.5; width: 140px; height: 41px;");
	//img.setAttribute('-moz-user-modify','read-only');
	//img.setAttribute('width',120);
	//img.setAttribute('height',90);

	img.setAttribute('src',data.url);
	img.setAttribute('_xo_id',data.name);
	img.setAttribute('title',data.name);

	sel = editor.getSelection();
	rng = editor.createRange(sel);
	rng.setEndAfter(img);
	rng.setStartAfter(img);
	