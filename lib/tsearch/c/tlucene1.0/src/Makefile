TCL_DIR = /opt/naviserver/include/
BOOST_DIR = /usr/include/boost/
LIB_DIR = /usr/local/lib
BOOST_DIR = /usr/include/boost/

default: client

client: tlucene.cpp
	g++ -Wall -O2 -fPIC -lthrift -I${TCL_DIR} -I/opt/clucene/include -I/opt/clucene/include/CLucene -I${BOOST_DIR}  -L/opt/clucene/lib -L/opt/naviserver/lib -c tlucene.cpp -o tlucene.o
	gcc -pipe -shared -lclucene -ltclstub8.5 -o tlucene1.0.so tlucene.o -L/opt/clucene/lib -L/opt/naviserver/lib -L${LIB_DIR}

clean:
	$(RM) -r *.so *.o

install:
	cp tlucene1.0.so /opt/naviserver/bin/