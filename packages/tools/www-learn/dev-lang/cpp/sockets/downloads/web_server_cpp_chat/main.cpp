/* Copyright (c) 2010 the authors listed at the following URL, and/or
the authors of referenced articles or incorporated external code:
http://en.literateprograms.org/Web_server_(C_Plus_Plus)?action=history&offset=20070123195116

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Web_server_(C_Plus_Plus)?oldid=8640
*/


#include"http.hpp"

#include<iostream>
#include<string>
#include<vector>

std::string frameset(
"<frameset rows=\"50%, 50%\">\n\
<frame src=\"top\" /> <frame src=\"bottom\" /> </frameset>\n"
);

std::string root("<html><head><title>Chat</title></head>"+frameset+"</html>");

struct chat_t {
	std::vector<std::string> msgs;
	std::string top(size_t howmany=10) {
		std::string ret(
"<html><head><meta http-equiv=\"refresh\" content=1 /></head>\n\
<body><table border=1><colgroup span=2><col width=\"10%\" /><col width=\"90%\"></colgroup>\n\
<tr><th>User id</th><th>Message</th></tr>\n"
);

		for(int n=(int)msgs.size()-howmany; n<(int)msgs.size(); ++n) {
			ret+=" <tr>";
			if(n>=0) ret+=msgs[n];
			else ret+="<td> </td><td> </td>";
			ret+="</tr>\n";
		}

		return ret+"</table></body></html>";
	}

	std::string bottom(std::map<std::string, std::string> formvalues) {
		std::string userid(formvalues["userid"]);
		if(userid.empty()) userid="anonymous";

		std::string msg(formvalues["msg"]);
		if(!msg.empty()) {
			msgs.push_back("<td>"+userid+"</td><td>"+msg+"</td>\n");
		}

		return std::string(
"<html><head></head><body>\n\
<form action=bottom method=\"get\" value=\""+userid+"\">\n\
<label for=userid>User id: </label><input type=text id=userid name=userid value=\""+userid+"\" />\n\
<label for=msg>Text: </label><input type=text size=100 id=msg name=msg />\n\
<input type=submit value=\"Send\" />\n\
</form>\n\
</body></html>\n"
);
	}
};

int main(int argc, char *argv[])
{
	try {
	int port(argc>1?atoi(argv[1]):80);
	chat_t chat;
	
	lp::http server(port);

	while(server.wait()) {
		const lp::http_request &request(server.request());
		if(!request.error.empty()) std::cerr<<"ERROR: "<<request.error<<'\n';

		if(request.method=="GET") {
			if(request.path=="/") server.reply(root, "text/html");
			else if(request.path.substr(0, 4)=="/top") 
				server.reply(chat.top(), "text/html");
			else if(request.path=="/bottom") 
				server.reply(chat.bottom(request.formvalues), "text/html");
			else server.error("404", "Not found "+request.path);
				
		} else {
			server.error("501", "Not implemented");
		}
	}
	} catch(lp::http_error &e) {
		std::cerr<<"Exception: "<<e.what()<<'\n';
	}

	return 0;
}



