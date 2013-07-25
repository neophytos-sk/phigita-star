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

#include<sys/socket.h>
#include<netinet/in.h>

namespace lp {
http::~http()
{
	if(m_cs>0) close(m_cs);
	if(m_ss>0) close(m_ss);
}

bool http::dorecv()
{

	char b[1024];
	int nrecv;

	if((nrecv=recv(m_cs, b, 1023, 0))<0) throw http_recv_error();

	if(!nrecv) return false;

	b[nrecv]='\0';
	m_rbuf+=b;
	return true;
}

std::string http::getline()
{
	std::string line;
	size_t ix;

	while((ix=m_rbuf.find('\n'))==std::string::npos) {
		if(!dorecv()) {
			line=m_rbuf;
			m_rbuf.erase();
			return line;
		}
	}

	line=m_rbuf.substr(0, ix);
	m_rbuf.erase(0, ix+1);

	if(!line.empty() && line[line.size()-1]=='\r') 
		line.erase(line.size()-1);	// Remove trailing '\r'
	return line;
}

void http::dosend(const std::string &s)
{
	if(send(m_cs, s.c_str(), s.size(), 0)!=(int)s.size()) throw http_send_error();
}

void http::setup()
{
	try {
	struct sockaddr_in addr;
	if((m_ss=socket(PF_INET, SOCK_STREAM, 0))==-1) throw http_socket_error();

	memset((void*)&addr, 0, sizeof addr);
	addr.sin_family=AF_INET;
	addr.sin_port=htons(m_port);
	addr.sin_addr.s_addr=INADDR_ANY;
	if(bind(m_ss, (struct sockaddr*)&addr, sizeof addr)==-1) throw http_bind_error();

	if(listen(m_ss, 1)==-1) throw http_listen_error();

	} catch(...) {
		if(m_ss>0) close(m_ss);
		m_ss=0;
		throw;
	}
}

bool http::wait(int timeout)
{

	if(!m_ss) setup();

	struct timeval tmout;
	struct timeval *ptmout;

	if(timeout) {
		tmout.tv_sec=timeout/1000;
		tmout.tv_usec=(timeout%1000)*1000;
		ptmout=&tmout;

	} else ptmout=NULL;

	fd_set rset;
	FD_ZERO(&rset);
	FD_SET(m_ss, &rset);

	if(select(m_ss+1, &rset, 0, 0, ptmout)>0) {

		struct sockaddr_in client_addr;
		socklen_t addrsize(sizeof client_addr);

		if((m_cs=accept(m_ss, (struct sockaddr*)&client_addr, &addrsize))==-1)
			throw http_accept_error();
	
		return true;

	} else return false;
}


std::string formvalue(const std::string &raw)
{
	std::string ret;
	for(size_t ix=0; ix<raw.size(); ++ix) {
		if(raw[ix]=='+') ret+=' ';
		else if(raw[ix]=='%') {
			int val(0);
			if(++ix<raw.size()) 
				val=16*(isalpha(raw[ix]) ? toupper(raw[ix])+10-'A' : raw[ix]-'0');
			if(++ix<raw.size()) 
				val+=isalpha(raw[ix]) ? toupper(raw[ix])+10-'A' : raw[ix]-'0';
			ret+=(char)val;
		} else ret+=raw[ix];
	}
	return ret;
}

void readformdata(const std::string &str, std::map<std::string, std::string> &formvalues)
{
	std::string name, value;
	bool reading_name(true);
	for(size_t ix=0; ix<str.size(); ++ix) {
		if(str[ix]=='=') {
			reading_name=false;
		} else if(str[ix]=='&') {
			formvalues[name]=formvalue(value);
			name.clear();
			value.clear();
			reading_name=true;
		} else if(reading_name) {
			name+=str[ix];
		} else {
			value+=str[ix];
		}
	}
	if(!name.empty()) formvalues[name]=formvalue(value);
}


const http_request &http::request()
{
	size_t ix;

	m_request.error.clear();
	m_request.method.clear();
	m_request.path.clear();
	m_request.version.clear();
	m_request.fields.clear();
	m_request.formvalues.clear();

	std::string line;

	if((line=getline()).empty()) m_request.error="Empty line";


	// Method
	if((ix=line.find_first_of(" \t"))!=std::string::npos) {
		m_request.method=line.substr(0, ix);
		line.erase(0, ix);
		while(!line.empty() && isspace(line[0])) line.erase(0, 1);


		// Path
		if((ix=line.find_first_of(" \t"))!=std::string::npos) {
			m_request.path=line.substr(0, ix);
			line.erase(0, ix);
			while(!line.empty() && isspace(line[0])) line.erase(0, 1);

			// Form data in URL
			if((ix=m_request.path.find('?'))!=std::string::npos) {
				std::string formdata(m_request.path.substr(ix+1));
				m_request.path=m_request.path.substr(0, ix);

				readformdata(formdata, m_request.formvalues);
			}


			// Version
			m_request.version=line;
		} else m_request.path=line;
	} else m_request.error="Syntax error";

	if(m_request.version.empty()) return m_request;	// Old style HTTP request


	// Fields
	while(!(line=getline()).empty()) {
		if((ix=line.find(':'))==std::string::npos) {
			m_request.error="Syntax error";
			return m_request;
		}
		std::string &value=m_request.fields[line.substr(0, ix)]=line.substr(ix+1);
		while(!value.empty() && isspace(value[0])) value.erase(0, 1);
	}

	return m_request;
}

void http::reply(const std::string &msg, const std::string &ctype)
{
	std::string header("HTTP/1.1 200 Ok\r\nContent-Type: "+ctype+"\r\n\r\n");
	dosend(header+msg);
	close(m_cs);
	m_cs=0;
}

void http::error(const std::string &code, const std::string &msg)
{
	std::string header("HTTP/1.1 "+code+" "+msg+"\r\nContent-type: text/plain\r\n\r\n");
	std::string data(msg+"\r\n");
	dosend(header+data);
	close(m_cs);
	m_cs=0;
}

} // namespace lp

