//This file contains all functions and variables related to the participants list and the chat sessions


ChatSession = {};
ChatSession.RefreshSessionInterval = 30 * 1000;//The time interval for calling the function RefreshSession

ChatSession.RefreshSession = function () {
    Server.load_resource("cmd=prefix_match&argv=CHAT.chatSession", "ChatSession.ShowActiveSessions");
}

ChatSession.ShowActiveSessions = function(obj) {
    var timestamp = Number(new Date());
    var latestActiveTimestamp = timestamp - ChatSession.RefreshSessionInterval;
    
    var participants = obj.data;
    

    xo.log(participants);
}


Participants = {}; //Object that helps us handle the participants' list
Participants.AddParticipantInterval = 10 * 1000; //The time interval for calling the function AddParticipant
Participants.DisplayListDiv = 'div_participants';


///AddParticipant is call to add the current user to the list of participants (with a timestamp)
//The timestamp is needed to show only the active participants
Participants.AddParticipant = function() {
	var timestamp = Number(new Date());
	var data = {"time":timestamp,"user":Chat.LoggedInUser};
	Server.load_resource("cmd=PUT&argv=CHAT.participant " + xo.encode(data), "Participants.GetParticipants");

}
//GetParticipants retrieves the participants' list from the server and calls show_participants to 
//display that list
Participants.GetParticipants = function() {
	Server.load_resource("cmd=prefix_match&argv=CHAT.participant", "show_participants");

}

Participants.MinimizePrivateChat = function(objid)
{
var objChatbox =  xo.getDom(objid);
if(objChatbox)
{

//objChatbox.style.display = "none";
objChatbox.style.bottom="-250px";
objChatbox.style.zIndex="-1";
return;

}


}


Participants.ClosePrivateChat = function(objid)
{

 
//bottomBar
var obj =  xo.getDom(objid);
var rightPos = obj.style.right;
	var bottomBar = xo.getDom("bottomBar");

Chat.NumberOfChats = Chat.NumberOfChats -1 ;



for(i=0; i < bottomBar.children.length; i++)
{

if(bottomBar.children[i].style.right > rightPos)
{

iniPos = bottomBar.children[i].style.right ;

iniPos =iniPos.substring(0,iniPos.length-2);
iniPos = iniPos - 250;

bottomBar.children[i].style.right =iniPos+"px";
}

}

bottomBar.removeChild(obj);

}


Participants.ShowExistingPrivateChat = function(obj)
{

    obj=obj.toLowerCase();
    var chatboxId =  "chatBox_" + obj;
    var objChatbox =  xo.getDom(chatboxId);
    
    if(objChatbox)
	{
	    objChatbox.style.position="fixed";
	    objChatbox.style.bottom="30px";
	    objChatbox.style.zIndex="1";
	    objChatbox.focus();
	    return;

	}

    var userClicked = obj;
    //window.open('PrivateChat.htm?User=' + userClicked + "&LUser=" + Chat.LoggedInUser, '_newwindow').focus();
    //Need to insert a div containing the private chat after the input chat message
    //1. Create the privateChat div
    //2. Add it after the input chat message
    
    Chat.NumberOfChats = Chat.NumberOfChats + 1;
    var targetPage = 'PrivateChat.htm?User=' + userClicked + "&LUser=" + Chat.LoggedInUser;
    var embedPage= '<object  data=' + targetPage +   ' height=270px width=200px ></object>';
    
    embedPage = "<div class='chatBoxControlBox'><span class='userName' onclick=Participants.ShowExistingPrivateChat('" +userClicked +"');>" + userClicked + "</span>   <span class='closeClass' onclick=Participants.ClosePrivateChat('chatBox_" +userClicked + "');>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class='minClass' onclick=Participants.MinimizePrivateChat('chatBox_" +userClicked + "')>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> </div>" + embedPage;
    
    var bottomBar = xo.getDom("bottomBar");
    
    
    var privateMessageDiv = xo.DomHelper.createDom({
	    "tag": "div",
	    "class": "chatbox",
	    "html": embedPage
	},bottomBar);
    
    privateMessageDiv.id = "chatBox_" + userClicked; 		
    
    
    
    
    
    var rightText = (Chat.NumberOfChats-1)*250;
    rightText = rightText + "px";
    
    privateMessageDiv.style.right = rightText;// ;
    
    
    
}
    
Participants.StartPrivateChat = function(e) {



	//open private chat in new tab

	var userClicked = e.target.childNodes[0].data;
userClicked = userClicked.toLowerCase();
 var chatboxId =  "chatBox_" + userClicked;
var objChatbox =  xo.getDom(chatboxId);

if(objChatbox)
{
objChatbox.style.position="fixed";
objChatbox.style.bottom="30px";
objChatbox.style.zIndex="1";
objChatbox.focus();
return;

}

	//window.open('PrivateChat.htm?User=' + userClicked + "&LUser=" + Chat.LoggedInUser, '_newwindow').focus();
//Need to insert a div containing the private chat after the input chat message
//1. Create the privateChat div
//2. Add it after the input chat message
Participants.ShowExistingPrivateChat(userClicked);

}



//This functions accepts as argument the participants' list as retrieved from the server
//and displays it in a div
function show_participants(obj) {

    
    var timestamp = Number(new Date()); // To define now
    //The last timestamp that the user is consider active
    //Every Participants.AddParticipantInterval miliseconds, the AddParticipant is called
    //Therefore if for the past Participants.AddParticipantInterval miliseconds since the last "refresh"
    //a participant has not been added to the list, then he has closed the window!
    var latestActiveTimestamp = timestamp - Participants.AddParticipantInterval;
    
    var participants = [];
    for(var i=0;i<obj.data.length;i++) {
	participants.push(xo.decode(obj.data[i]));
    }

    var divParticipantsArea = xo.getDom(Participants.DisplayListDiv);

    for (var i=0;i<participants.length;i++) {
	var id = "participant_" + participants[i]["user"];
	if (document.getElementById(id)) continue;
	var participantDiv = xo.DomHelper.createDom({
		"tag": "div",
		"id" : id,
		"html": participants[i]["user"]
	    }, divParticipantsArea);
	participantDiv.onclick = Participants.StartPrivateChat;
	
    }



    var currentTimeStamp = xo.getDom("currentTimeStamp");
    
    if(currentTimeStamp){
	currentTimeStamp.value = timestamp;
    }
    var latestTimeStamp = xo.getDom("latestTimeStamp");
    if(latestTimeStamp){
	latestTimeStamp.value = latestActiveTimestamp;}
    

}







/////
