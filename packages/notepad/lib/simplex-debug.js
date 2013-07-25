
store._update = store.update;
store.update = function(o, key, value) {
    if (!o) xo.log('ERROR: object not found in store.update');
    store._update(o,key,value);
}

err = function(id, errMsg) {
    var objCurr = store.find(id);
    var out = "";
    for(var i=0;i<objCurr.length;i++) {
	out += (" '" + objCurr[i] + "'");
    }
    xo.log(out);
    xo.log('check #' + id + ": " + objCurr[_text_]);
    xo.log(' prev:' + objCurr[_prev_] + ' ' + 'next:' + objCurr[_next_]);
    xo.log(' prevSibling:' + objCurr[_prevSibling_] + ' ' + 'nextSibling:' + objCurr[_nextSibling_]);
    xo.log(errMsg);
    return false;
}


store.isConsistent = function() {
    var rootId,lastId;
    for (var id in store.__NODES) {
	var objCurr = store.__NODES[id];
	if (Simplex.isTheStart(objCurr)) rootId=id;

	// check the types (whether they are correct) of the member elements of objCurr according to spec/protocol

	if (objCurr.length != 11) {
	    return err(id, "wrong array length: " + objCurr.length);
	}

	if (objCurr[_collapsed_] != 0 && objCurr[_collapsed_] != 1) {
	    return err(id, "invalid value '" + objCurr[_collapsed_] + "' for objCurr[_collapsed_]");
	}
	if (objCurr[_completed_] != 0 && objCurr[_completed_] != 1) {
	    return err(id, "invalid value '" + objCurr[_completed_] + "' for objCurr[_completed_]");
	}

	if (objCurr[_prev_] && objCurr[_prev_]!="" && !store.__NODES[objCurr[_prev_]]) 
	    return err(id, 'objCurr[_prev_] is undefined');
	if (objCurr[_next_] && objCurr[_next_]!="" && !store.__NODES[objCurr[_next_]]) 
	    return err(id, 'objCurr[_next_] is undefined');
	if (objCurr[_prevSibling_] && objCurr[_prevSibling_]!="" && !store.__NODES[objCurr[_prevSibling_]]) 
	    return err(id, 'objCurr[_prevSibling_] is undefined');
	if (objCurr[_nextSibling_] && objCurr[_nextSibling_]!="" && !store.__NODES[objCurr[_nextSibling_]]) 
	    return err(id, 'objCurr[_nextSibling_] is undefined');
	if (objCurr[_parent_] && objCurr[_parent_]!="" && !store.__NODES[objCurr[_parent_]]) 
	    return err(id, 'objCurr[_parent_] is undefined');

	// check that all of my linkes, i.e. parent,next,prev exist
	var objPrev = store.find(objCurr[_prev_]);
	var objPrevSibling = store.find(objCurr[_prevSibling_]);
	var objNext = store.find(objCurr[_next_]);
	var objNextSibling = store.find(objCurr[_nextSibling_]);
	var objParent = store.find(objCurr[_parent_]);

	// make sure i'm not pointing to my self

	if (objCurr[_next_] == objCurr[_id_]) 
	    return err(id, 'objCurr[_next_] = objCurr[_id_]');

	if (objCurr[_prev_] == objCurr[_id_]) 
	    return err(id, 'objCurr[_prev_] = objCurr[_id_]');

	if (objCurr[_nextSibling_] == objCurr[_id_]) 
	    return err(id, 'objCurr[_nextSibling_] = objCurr[_id_]');

	if (objCurr[_prevSibling_] == objCurr[_id_]) 
	    return err(id, 'objCurr[_prevSibling_] = objCurr[_id_]');


	// make sure my prev,next,parent exist
	if (objCurr[_prev_] && !objPrev) 
	    return err(id, '!objPrev && objCurr[_prev_]='+objCurr[_prev_]);

	if (objCurr[_next_] && !objNext) 
	    return err(id, '!objNext && objCurr[_next_]='+objCurr[_next_]);

	if (objCurr[_parent_] && !objParent) 
	    return err(id, '!objParent && objCurr[_parent_]='+objCurr[_parent_]);

	// make sure that i am my next's prev
	if (objNext && objNext[_prev_] != objCurr[_id_]) 
	    return err(id, 'objNext && objNext[_prev_]='+objNext[_prev_] + ' != ' + 'objCurr[_id_]='+objCurr[_id_]);

	// ditto for nextSibling, prevSibling
	if (objNextSibling && objNextSibling[_prevSibling_] != objCurr[_id_]) 
	    return err(id, 'objNextSibling && objNextSibling[_prevSibling_]='+objNextSibling[_prevSibling_] + ' != ' + 'objCurr[_id_]='+objCurr[_id_]);

	// and my prev's next
	if (objPrev && objPrev[_next_] != objCurr[_id_]) 
	    return err(id, 'objPrev && objPrev[_next_]='+objPrev[_next_] + ' != ' + 'objCurr[_id_]='+objCurr[_id_]);

	// ditto for prevSibling, nextSibling
	if (objPrevSibling && objPrevSibling[_nextSibling_] != objCurr[_id_]) 
	    return err(id, 'objPrevSibling && objPrevSibling[_nextSibling_]='+objPrevSibling[_nextSibling_] + ' != ' + 'objCurr[_id_]='+objCurr[_id_]);

	if (objPrev && objNextSibling && objPrev[_id_] == objNextSibling[_id_])
	    return err(id, 'objPrev-' + objPrev[_id_] + ' == objNextSibling-' + objNextSibling[_id_]);

	if (objNext && objPrevSibling && objNext[_id_] == objPrevSibling[_id_])
	    return err(id, 'objNext-' + objNext[_id_] + ' == objPrevSibling-' + objPrevSibling[_id_]);

	if (!objNext) lastId = id;

    }

    var objZoomStart=store.__NODES[Simplex.__zoomStart];
    var objZoomEnd=store.__NODES[Simplex.__zoomEnd];
    if ( objZoomStart && objZoomStart[_parent_] == "" && objZoomStart[_prev_] ) return err(Simplex.__zoomStart,"__zoomStart has prev");
    if ( objZoomEnd && objZoomEnd[_parent_] == "" && objZoomEnd[_next_] ) return err(Simplex.__zoomEnd,"__zoomEnd has next");

    //if (Simplex.__zoomStart != rootId) return false;
    //xo.log('lastId: ' + lastId + ' __zoomEnd: ' + Simplex.__zoomEnd);
    if (lastId && objZoomEnd[_parent_]=="" && Simplex.__zoomEnd != lastId) return err(lastId,"lastId != zoomEnd");
    // xo.log('zoom root and last: ok');
    return true;
};

