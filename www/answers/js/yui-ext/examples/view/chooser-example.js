/*
 * yui-ext
 * Copyright(c) 2006, Jack Slocum.
 */

YAHOO.ext.EventManager.onDocumentReady(function(){
    var chooser, btn;
    
    var insertImage = function(data){
    	YAHOO.ext.DomHelper.append('images', {
    		tag: 'img', src: data.url, style:'margin:10px;visibility:hidden;'
    	}, true).show(true);
    	btn.getEl().focus();
    };
    
    var choose = function(btn){
    	if(!chooser){
    		chooser = new ImageChooser({
    			url:'get-images.php',
    			width:515, 
    			height:400
    		});
    	}
    	chooser.show(btn.getEl(), insertImage);
    };
    
    btn = new YAHOO.ext.Button('buttons', {
	    text: "Insert Image",
		handler: choose
	});
});