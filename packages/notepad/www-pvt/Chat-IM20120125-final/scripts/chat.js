Chat = {};

// JavaScript Document


function getPlayer(pid) {
	var obj = document.getElementById(pid);
	if (obj.doPlay) return obj;
	for(i=0; i<obj.childNodes.length; i++) {
		var child = obj.childNodes[i];
		if (child.tagName == "EMBED") return child;
	}
}
function doPlay(filename) {
	var player=getPlayer("audio1");
	player.play(filename);
}
function doStop() {
	var player=getPlayer("audio1");
	player.doStop();
}


function playSound() {
    return;
	try { 
	  doPlay(); 
	} catch(ex) { 
	  xo.log(ex);
	};

}

var qsParm = new Array();
function qs() {
	var query = window.location.search.substring(1);
	var parms = query.split('&');
	for (var i = 0; i < parms.length; i++) {
		var pos = parms[i].indexOf('=');
		if (pos > 0) {
			var key = parms[i].substring(0, pos);
			var val = parms[i].substring(pos + 1);
			qsParm[key] = val;
		}
	}
}



Chat.appendMessage = function(msg) {

    var divChatArea = xo.getDom('div_chatarea');

    var timeStamp = msg["time"];
    if (timeStamp > Chat.LastMessageReceived) {
	Chat.LastMessageReceived = timeStamp;
    } else {
	return;
    }

    //Add Div holding the text a user entered in a line
    var theMessage = msg["user"] + ": " + msg["message"];
    xo.DomHelper.createDom({"tag": "div","class": "message","html": theMessage}, divChatArea);
}


function show_data(o) {

    var msgs = [];
    var dataLen = o.data.length;
    if (dataLen==0) return;
    for(var i=0;i<dataLen;i++) {
	try {
	    var obj = xo.decode( o.data[i] );
	} catch(ex) {
	    xo.log('failed to read msg: ' + o.data[i]);
	    continue;
	}
	msgs.push(obj);
    }


    var divChatArea = xo.getDom('div_chatarea');

    for (var i=0; i < msgs.length; i++) {
	Chat.appendMessage(msgs[i]);
    }

    divChatArea.scrollTop = divChatArea.scrollHeight;



}

function scrollToBottom (){

    var divChatArea = xo.getDom('div_chatarea');
    divChatArea.scrollTop = divChatArea.scrollHeight;
}

function sync_message_from_server(data){

    if (data.channel == 'chat_messages') {

	var divChatArea = xo.getDom('div_chatarea');
	xo.DomHelper.createDom({
		"tag": "div",
		    "class": "message",
		    "html": data.message
		    }, divChatArea);
	divChatArea.scrollTop = divChatArea.scrollHeight;
	playSound();
    } else if (data.channel == 'chat_participants')  {
	// do nothing for now
    } else if (data.channel == 'chat_sharedraw') {
	//xo.log(data.message);
	var obj = xo.decode('{'+data.message+'}');
	//for (var i in obj) {
	//    obj[i] = xo.decode(obj[i]);
	//}
	xo.log(obj);
        state.__setState(obj);
	context.strokeStyle = "rgba(255,0,0,0.5)";  
	Controller.stateUpdated();
	context.strokeStyle = "";  
	playSound();
    }

    subscribe_fun(data.channel);

}

//function sync_message_from_server(data) {
//console.log(data); // auto tha to kanei log stin konsola tou firebug
//}


function subscribe_fun(channel) {   
    Server.load_resource("cmd=subscribe&argv="+channel,null);
}


function cb_PUT(oMsg) {
    // do nothing for now
}




Chat.ChatPartner = "";
Chat.LastMessageReceived = 0;
Chat.Prefix = "CHAT.message";
Chat.SendMessage = function() {


    var el = xo.getDom('chat_message');
    var timestamp = Number(new Date());
    var timeValue =  (new Date).getTime();
    //var data = timestamp + Chat.LoggedInUser + ": " + el.value;
    var data =  Chat.LoggedInUser + ": " + el.value;
    var oMsg = {"time":timestamp,"user":Chat.LoggedInUser,"message":el.value};
    Chat.appendMessage(oMsg);

    if(Chat.Prefix.indexOf(  "CHAT.pmessage") > -1) {
	//Then a private message is about to be sent
	//Add a session entry in ChatSession
	    
	//	var session_data = timestamp + ":" + Chat.ChatPartner  + ":" + Chat.LoggedInUser ;
	var session_data =  Chat.ChatPartner  + ":" + Chat.LoggedInUser ;
	var session_data2 = timestamp + ":" + Chat.ChatPartner  + ":" + Chat.LoggedInUser ;
	    
	//sync_message_from_server( xo.encode(session_data) );
	    
	    
	    
	//Server.load_resource("cmd=publish&argv=test "+xo.encode(data),null)
	Server.load_resource("cmd=publish&argv=test " + xo.encode(session_data) + "&_t=" + timeValue,null);
	Server.load_resource("cmd=PUT&callback=cb_PUT&argv=CHAT.chatSession " + xo.encode(session_data2) , null);
	el.value = "";
	return;
    }

    //sync_message_from_server(  xo.encode(data));
    

    
    Server.load_resource("cmd=publish&argv=test " +  xo.encode(data) + "&_t=" + timeValue,null);
    Server.load_resource("cmd=PUT&callback=cb_PUT&argv=" + Chat.Prefix + "-" + timestamp + " " + xo.encode(oMsg),null);
    
    el.value = "";
    
    
}

Chat.GetMessages = function() {
    Server.load_resource("cmd=prefix_match&argv=" + Chat.Prefix, "show_data");
    Participants.GetParticipants();
}



//Code initialy in Chat.htm

 function render_msg(msg) {
            ///This function gets a msg in the form
            /// author:
            /// msg:
            //        var divEl = xo.getDom('');
            //        var el = xo.DomHelper.createDom({
            //            "tag": "div",
            //            "class": "message",
            //            "html": "User " + msg.author + ": " + msg.data
            //        }, divEl);
            //    
        }



        /**/
function getSplittedData(dataSet, splitValue) {
    xo.log(dataSet);
    return dataSet;
};
        //http://api.phigita.net/simplex/test?cmd=delete&argv=CHAT.participant

        /*               CHAT AREA                                  */

        //GG: Gets the messages stored so far
        //Adds only the new messages based on variable Chat.LastMessageReceived

      

    

        /*  END OF CHAT AREA   */


        /* PARTICIPANTS */

        

  




      function no_callback(){}
Server = {};
Server.baseURL = "http://api.phigita.net/simplex/test?";
Server.load_resource = function(query, callback) {
var script = xo.DomHelper.createDom({ "tag": "script", "type": "text/javascript" }, document.getElementsByTagName("head")[0]);
var srcUrl = Server.baseURL + query;
if(callback) {
srcUrl = srcUrl + "&callback=" + callback;
}
script.src = srcUrl;
};



Chat.RefreshInterval = 10*1000;
window.setInterval(Chat.GetMessages, Chat.RefreshInterval);
//window.setInterval(Participants.AddParticipant, Participants.AddParticipantInterval);
//window.setInterval(ChatSession.RefreshSession,ChatSession.RefreshSessionInterval);

function quickMessageSend(event) {
    if (event.keyCode == 13) {
	Chat.SendMessage();
    }    
}




Chat.init = function() {

    //loggedInUser = xo.getDom('participantList');
    //Chat.LoggedInUser = loggedInUser.value;
    var randomnumber = Math.floor(Math.random() * 5)
    var randomUsers = {};
    randomUsers[0] = "Neophytos";
    randomUsers[1] = "Marios";
    randomUsers[2] = "Georgia";
    randomUsers[3] = "Antonis";
    randomUsers[4] = "Stylianos";
     
    Chat.LoggedInUser = randomUsers[randomnumber];
    Chat.GetMessages();
    Participants.AddParticipant();

    var participantList = xo.getDom("participantList");
    if(participantList){
	participantList.value=Chat.LoggedInUser ;}
    //            xo.Event.on('send_btn', 'click', Chat.SendMessage);
    xo.Event.on('chat_message', 'keyup', quickMessageSend);
    //On page load - load the messages of the day

    Chat.NumberOfChats =0;

    // TODO: GEORGIA COMMENT IN ONLY ONE OF THE FOLLOWING LINES
    // subscribe_fun('chat_messages');
    // subscribe_fun('chat_participants');
    subscribe_fun('chat_sharedraw');

};

var Widget = {
    instanceid_key: 'chat_messages'
};

var WaveImpl = {};

WaveImpl.getParticipants = function(instanceid_key, callback) {
    //  xo.log('getParticipants: instanceid_key=' + instanceid_key);
};

WaveImpl.getViewer = function(instanceid_key,callback) {
    // xo.log('getViewer: instanceid_key=' + instanceid_key);
};


WaveImpl.state = function(instanceid_key,callback) {
    xo.log('sharedDataForKey: '+instanceid_key);
    //return WidgetImpl.sharedDataForKey(instanceid_key,'defaultWave',callback);
};

WaveImpl.submitDelta = function(instanceid_key,thedelta) {
    Server.load_resource("cmd=publish&format=sharedraw&argv=chat_sharedraw " + xo.encode(thedelta),null);
    //xo.log('appendSharedDataForKey: '+instanceid_key);
    //xo.log('thedelta: '+xo.encode(thedelta));
//return WidgetImpl.appendSharedDataForKey(instanceid_key,'defaultWave',JSON.stringify(thedelta),WaveImpl.successFn);
}

WaveImpl.successFn = function(reply) {
    xo.log('success: ' + reply);
};

