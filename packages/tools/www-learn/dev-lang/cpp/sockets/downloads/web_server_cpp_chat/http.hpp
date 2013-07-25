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

#ifndef HTTP_HPP_INCLUDE_GUARD
#define HTTP_HPP_INCLUDE_GUARD

#include<string>
#include<map>

namespace lp {
struct http_error {
	virtual const char *what()=0;
	virtual ~http_error() {}
};
struct http_socket_error: http_error {
	const char *what() {return "socket()";}
};
struct http_bind_error: http_error {
	const char *what() {return "bind()";}
};
struct http_listen_error: http_error {
	const char *what() {return "listen()";}
};
struct http_accept_error: http_error {
	const char *what() {return "accept()";}
};
struct http_recv_error: http_error {
	const char *what() {return "recv()";}
};
struct http_send_error: http_error {
	const char *what() {return "send()";}
};

struct http_request {
	std::string error;
	std::string method;
	std::string path;
	std::string version;
	std::map<std::string, std::string> fields;
	std::map<std::string, std::string> formvalues;
};

class http {
	int m_port;
	std::string m_path;
	int m_cs;		// Client socket
	int m_ss;		// Server socket
	std::string m_rbuf;
	http_request m_request;

	void setup();
	bool dorecv();
	std::string getline();
	void dosend(const std::string &);
public:
	http(int port): m_port(port), m_cs(0), m_ss(0) {}
	~http();
	bool wait(int timeout=0);
	const http_request &request();
	void reply(const std::string &data, const std::string &ctype);
	void error(const std::string &code, const std::string &msg);
};

} // namespace lp
#endif

