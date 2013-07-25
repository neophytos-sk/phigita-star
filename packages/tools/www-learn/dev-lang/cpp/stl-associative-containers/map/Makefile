all: simplemap1 simplemap2 reserved-keywords compose-maps

simplemap1:
	g++ -o simplemap1 simplemap1.cpp

simplemap2:
	g++ -o simplemap2 simplemap2.cpp

reserved-keywords:
	g++ -o reserved-keywords reserved-keywords.cpp

compose-maps:
	g++ -o compose-maps ComposeMaps.cc

test: all
	./simplemap1
	./simplemap2
	./reserved-keywords
	./compose-maps

clean:
	rm -f simplemap1 simplemap2 reserved-keywords compose-maps *~
