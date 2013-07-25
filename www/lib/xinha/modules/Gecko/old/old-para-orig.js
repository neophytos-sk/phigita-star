
	return true;
	alert('okXXXX');

	alert('ok1');
	if (_xo_first_ancestor_node && _xo_first_ancestor_node.nodeType == Node.ELEMENT_NODE )
	{
		if (_xo_first_ancestor_node.innerHTML.replace(_xo_regexp,"").length == 0) {
			Xinha._stopEvent(ev);
			return true;
		}
	}
	alert('ok2');

	//AK Change3 (den einai etoimo akoma)
	if (getTagName(_xo_first_ancestor_node) == "code")
	{
		var _xo_re = /<br>(\&nbsp\;|\<[^\>]*\>|\s)*<br>(\&nbsp\;|\<[^\>]*\>|\s)*$/gi;
		//alert(_xo_first_ancestor_node.innerHTML);
		//alert(_xo_first_ancestor_node.innerHTML.search(_xo_re));
		if (_xo_first_ancestor_node.innerHTML.search(_xo_re) != -1)
		{
			//alert("end of paragraph");
			_xo_first_ancestor_node.innerHTML = _xo_first_ancestor_node.innerHTML.replace(_xo_re,"");
		}
		else 
		{
			//var r = rng.duplicate();
			this.editor.insertHTML("<br>","");
			//rng.setEnd(r.endContainer,r.endOffset);
			//rng.collapse(true);
			//rng.setEnd(rng.endContainer,rng.endOffset+1);
			//rng.setStart(rng.startContainer,rng.startOffset+1);
			/*rng.moveEnd("character",1);
			rng.setEndPoint("StartToEnd",rng);
			rng.select();
			rng.moveStart("character",-1);
			rng.setEndPoint("EndToStart",rng);
			rng.select();*/
			Xinha._stopEvent(ev);
			return true;
		}
	}
	//AK Change3 --end
	


	if (_xo_first_ancestor_node.nextSibling && _xo_first_ancestor_node.nextSibling.nodeType == Node.ELEMENT_NODE)
	{
		_xo_end_container = rng.endContainer;
		_xo_end_offset = rng.endOffset;
		_xo_start_container = rng.startContainer;
		_xo_start_offset = rng.startOffset;

		rng.setStart(_xo_end_container,_xo_end_offset);
		rng.setEndAfter(_xo_first_ancestor_node);
		_xo_text_to_end = rng.toString();
		rng.setStart(_xo_start_container,_xo_start_offset);
		rng.setEnd(_xo_end_container,_xo_end_offset);

		if (_xo_first_ancestor_node.nextSibling && _xo_first_ancestor_node.nextSibling.innerHTML.replace(_xo_regexp,"").length == 0 && _xo_text_to_end.replace(_xo_regexp,"").length == 0) {

			rng.deleteContents();
			rng.setEnd(_xo_first_ancestor_node.nextSibling,0);
			rng.setStart(_xo_first_ancestor_node.nextSibling,0);

			Xinha._stopEvent(ev);
			return true;
		}
	}


	if (_xo_first_ancestor_node.previousSibling && _xo_first_ancestor_node.previousSibling.nodeType == Node.ELEMENT_NODE)
	{
		_xo_start_container = rng.startContainer;
		_xo_start_offset = rng.startOffset;
		_xo_end_container = rng.endContainer;
		_xo_end_offset = rng.endOffset;

		rng.setStart(_xo_first_ancestor_node,0);
		rng.setEnd(_xo_start_container,_xo_start_offset);
		_xo_text_to_start = rng.toString();
		rng.setStart(_xo_start_container,_xo_start_offset);
		rng.setEnd(_xo_end_container,_xo_end_offset);


		if (_xo_first_ancestor_node.previousSibling && _xo_first_ancestor_node.previousSibling.innerHTML.replace(_xo_regexp,"").length == 0 && _xo_text_to_start.replace(_xo_regexp,"").length == 0) {
			rng.deleteContents();
			Xinha._stopEvent(ev);
			return true;
		}
	}
	//AK Change3
	//to ekana etsi epeidi den thelw na peiraksw olo ton kwdika edw giati mporei na dyskoleuteis
	//na deis tis allages .. protimisa na to kanw copy paste kai na allaksw to previousSibling me
	//parentNode.previousSibling
	//douleuei pantws
	else if (_xo_first_ancestor_node.parentNode.previousSibling && _xo_first_ancestor_node.parentNode.previousSibling.nodeType == Node.ELEMENT_NODE)
	{
		_xo_start_container = rng.startContainer;
		_xo_start_offset = rng.startOffset;
		_xo_end_container = rng.endContainer;
		_xo_end_offset = rng.endOffset;

		rng.setStart(_xo_first_ancestor_node,0);
		rng.setEnd(_xo_start_container,_xo_start_offset);
		_xo_text_to_start = rng.toString();
		rng.setStart(_xo_start_container,_xo_start_offset);
		rng.setEnd(_xo_end_container,_xo_end_offset);


		if (_xo_first_ancestor_node.parentNode.previousSibling && _xo_first_ancestor_node.parentNode.previousSibling.innerHTML.replace(_xo_regexp,"").length == 0 && _xo_text_to_start.replace(_xo_regexp,"").length == 0) {
			rng.deleteContents();
			Xinha._stopEvent(ev);
			return true;
		}
	}
	//AK Change3 --end
	
	//AK Change2
	if ( this.isNormalListItem(rng) )
		return true;
	//AK Change2
	//AK Change --end
*/
