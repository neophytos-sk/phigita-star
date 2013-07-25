
/**
 * xo_objpool
 * 
 * Modern garbage collectors might decide to collect the garbage when it's not convenient,
 * and collecting the garbage might introduce delays. This can manifest when you are creating
 * and discarding a large number of objects very quickly. The general solution is to stop
 * allocating temporary objects, and reuse existing ones. You can keep a "pool" of unused
 * instances of objects on stand-by, and just pull objects out of it when they are needed.
 * 
 * This way the garbage collector has a lot less work to do, since nothing is every collected;
 * every object is either in-use, or stored idle in the object pool.
 * 
 */
function xo_objpool(cls, nocleanup) {
  var _cls = cls || Object;
  var _nocleanup = nocleanup;
  var _objpool = [];
  var _metrics = {totalreq:0, totalalloc:0, totalfree:0,length_of_pool:0};
  
  var self = {
    alloc: function() {
      
	var obj;
	
	_metrics.totalreq++;
	
	if (_objpool.length == 0) {
		// nothing in the free list, so allocate a new object
		obj = new _cls();
		_metrics.totalalloc++;
		
	} else {
		// grab one from the top of the objpool
		obj = _objpool.pop();
		_metrics.totalfree--;
	}
	
	return obj;
    },
    free: function(obj) {
	
	// fix up the free list pointers
	_objpool.push(obj);
	
	_metrics.totalfree++;
	
	// clean up the object
	if (!_nocleanup)
	  for (var p in obj)
	    if (obj.hasOwnProperty(p))
	      delete obj[p];
    },
    metrics: function() {
      _metrics.length_of_pool = _objpool.length;
      return _metrics;
    }
  }
  return self;
}
