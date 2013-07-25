

xo.Ajax = {
	timeout:{},
	poll:{},

	pollInterval:50,
	transactionId:0,
	activeX:[
        'MSXML2.XMLHTTP.3.0',
        'MSXML2.XMLHTTP',
        'Microsoft.XMLHTTP'
        ]
};

xo.Ajax.createXhrObject = function(transactionId) {
        var obj,http;
        try {
            http = new XMLHttpRequest();
            obj = { conn:http, tId:transactionId };
        } catch(e) {
            for (var i = 0; i < xo.Ajax.activeX.length; ++i) {
                try {
                    http = new ActiveXObject(xo.Ajax.activeX[i]);
                    obj = { conn:http, tId:transactionId };
                    break;
                } catch(e) {
                }
            }
        } finally {
            return obj;
        }
};

xo.Ajax.getConnectionObject = function() {
        var o;
        var tId = xo.Ajax.transactionId;
        
        try {
            o = xo.Ajax.createXhrObject(tId);
            if (o) {
                xo.Ajax.transactionId++;
            }
        } catch(e) {
        } finally {
            return o;
        }
};

xo.Ajax.asyncRequest = function(url,callback,postData) {
    var o = xo.Ajax.getConnectionObject();
    if (!o) {
        return null;
    } else {
	var method = (postData) ? "POST" : "GET";
        o.conn.open(method, url, true);
	if (method=="POST") {
	    //Send the proper header information along with the request
	    o.conn.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	    o.conn.setRequestHeader("Content-length", postData.length);
	    o.conn.setRequestHeader("Connection", "close");
	}

        xo.Ajax.handleReadyState(o, callback);
        o.conn.send(postData || null);
        return o;
    }
};

xo.Ajax.handleReadyState = function(o, callback) {

        if (callback && callback.timeout) {
            xo.Ajax.timeout[o.tId] = window.setTimeout(function() {
                    xo.Ajax.abort(o, callback, true);
                }, callback.timeout);
        }

        xo.Ajax.poll[o.tId] = window.setInterval(
            function() {
                if (o.conn && o.conn.readyState == 4) {
                    window.clearInterval(xo.Ajax.poll[o.tId]);
                    delete xo.Ajax.poll[o.tId];

                    if (callback && callback.timeout) {
                        window.clearTimeout(xo.Ajax.timeout[o.tId]);
                        delete oConn.timeout[o.tId];
                    }

                    xo.Ajax.handleTransactionResponse(o, callback);
                }
            }
            , xo.Ajax.pollInterval);

};

xo.Ajax.handleTransactionResponse = function(o, callback, isAbort) {
        if (!callback) {
            xo.Ajax.releaseObject(o);
            return;
        }

        var httpStatus, responseObject;

        try {
            if (o.conn.status !== undefined && o.conn.status != 0) {
                httpStatus = o.conn.status;
            } else {
                httpStatus = 13030;
            }
        } catch(e) {
            httpStatus = 13030;
        }

        if (httpStatus >= 200 && httpStatus < 300) {
            responseObject = xo.Ajax.createResponseObject(o, callback["argument"]);
            if (callback["success"]) {
                if (!callback.scope) {
                    callback["success"](responseObject);
                } else {
                    callback["success"].apply(callback.scope, [responseObject]);
                }
            }
        } else {
            switch (httpStatus) {
            case 12002:
            case 12029:
            case 12030:
            case 12031:
            case 12152:
            case 13030:
            responseObject = xo.Ajax.createExceptionObject(o.tId, callback["argument"], (isAbort ? isAbort : false));
            if (callback["failure"]) {
                if (!callback.scope) {
                    callback["failure"](responseObject);
                } else {
                    callback["failure"].apply(callback.scope, [responseObject]);
                }
            }
            break;
            default:
            responseObject = xo.Ajax.createResponseObject(o, callback["argument"]);
            if (callback["failure"]) {
                if (!callback.scope) {
                    callback["failure"](responseObject);
                }
                else {
                    callback["failure"].apply(callback.scope, [responseObject]);
                }
            }
            }
        }

        xo.Ajax.releaseObject(o);
        responseObject = null;
    }

xo.Ajax.createResponseObject = function(o, callbackArg) {
    var obj = {};
    obj["tId"] = o.tId;
    obj["status"] = o.conn.status;
    obj["responseText"] = o.conn.responseText;
    
    if (typeof callbackArg !== undefined) {
        obj["argument"] = callbackArg;
    }

    return obj;
};

xo.Ajax.createExceptionObject =function(tId, callbackArg, isAbort)
    {
        var COMM_CODE = 0;
        var COMM_ERROR = 'communication failure';
        var ABORT_CODE = -1;
        var ABORT_ERROR = 'transaction aborted';

        var obj = {};

        obj["tId"] = tId;
        if (isAbort) {
            obj["status"] = ABORT_CODE;
            obj["statusText"] = ABORT_ERROR;
        }
        else {
            obj["status"] = COMM_CODE;
            obj["statusText"] = COMM_ERROR;
        }

        if (callbackArg) {
            obj["argument"] = callbackArg;
        }

        return obj;
    };

xo.Ajax.abort = function(o, callback, isTimeout) {
        if (this.isCallInProgress(o)) {
            o.conn.abort();
            window.clearInterval(xo.Ajax.poll[o.tId]);
            delete xo.Ajax.poll[o.tId];
            if (isTimeout) {
                delete xo.Ajax.timeout[o.tId];
            }

            xo.Ajax.handleTransactionResponse(o, callback, true);

            return true;
        } else {
            return false;
        }
    };

xo.Ajax.isCallInProgress = function(o) {
        if (o.conn) {
            return o.conn.readyState != 4 && o.conn.readyState != 0;
        } else {
            return false;
        }
    };

xo.Ajax.releaseObject = function(o) {
        o.conn = null;
        o = null;
    };


