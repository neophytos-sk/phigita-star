
/**
* Create a DragZone instance for our JsonView
*/
Ext.ux.ImageDragZone = function(view, config){
    this.view = view;
    Ext.ux.ImageDragZone.superclass.constructor.call(this, view.getEl(), config);
};
Ext.extend(Ext.ux.ImageDragZone, Ext.dd.DragZone, {
    // We don't want to register our image elements, so let's 
    // override the default registry lookup to fetch the image 
    // from the event instead
    getDragData : function(e){
	var target = e.getTarget('.thumb-wrap');
	if(target){
	    var view = this.view;
	    if(!view.isSelected(target)){
		view.onClick(e);
	    }
	    var selNodes = view.getSelectedNodes();
	    var dragData = {
		nodes: selNodes
	    };
	    if(selNodes.length == 1){
		dragData.ddel = target.firstChild.firstChild; // the img element
		dragData.single = true;
	    }else{
		var div = document.createElement('div'); // create the multi element drag "ghost"
		div.className = 'multi-proxy';
		for(var i = 0, len = selNodes.length; i < len; i++){
								    div.appendChild(selNodes[i].firstChild.firstChild.cloneNode(true));
								    if((i+1) % 3 == 0){
									div.appendChild(document.createElement('br'));
								    }
								}
		dragData.ddel = div;
		dragData.multi = true;
	    }
	    return dragData;
	}
	return false;
    },

    // this method is called by the TreeDropZone after a node drop
    // to get the new tree node (there are also other way, but this is easiest)
    getTreeNode : function(){
	var treeNodes = [];
	var nodeData = this.view.getRecords(this.dragData.nodes);
	for(var i = 0, len = nodeData.length; i < len; i++){
							    var data = nodeData[i].data;
							    treeNodes.push(new Ext.tree.TreeNode({
								text: data.shortName,
								icon: data.url,
								data: data,
								leaf:true,
								cls: 'image-node'
							    }));
							}
	return treeNodes;
    },
    
    // the default action is to "highlight" after a bad drop
    // but since an image can't be highlighted, let's frame it 
    afterRepair:function(){
	for(var i = 0, len = this.dragData.nodes.length; i < len; i++){
								       Ext.fly(this.dragData.nodes[i]).frame('\#8db2e3', 1);
								   }
	this.dragging = false;    
    },
    
    // override the default repairXY with one offset for the margins and padding
    getRepairXY : function(e){
	if(!this.dragData.multi){
	    var xy = Ext.Element.fly(this.dragData.ddel).getXY();
	    xy[0]+=3;xy[1]+=3;
	    return xy;
	}
	return false;
    }
});

