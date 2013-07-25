CC = g++


all: 	listing1 listing2 listing3 listing4 listing5

listing1:
	$(CC) -o listing1 listing1.cc -lboost_thread

listing2:
	$(CC) -o listing2 listing2.cc -lboost_thread -lboost_thread-mt

listing3:
	$(CC) -o listing3 listing3.cc -lboost_thread -lboost_thread-mt

listing4:
	$(CC) -o listing4 listing4.cc -lboost_thread -lboost_thread-mt

listing5:
	$(CC) -o listing5 listing5.cc -lboost_thread -lboost_thread-mt

clean:
	rm listing1 listing2 listing3 listing4 listing5