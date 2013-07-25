all: document_distance document_distance_log_scale

document_distance_log_scale:
	g++ -o document_distance_log_scale document_distance_log_scale.cc

document_distance:
	g++ -o document_distance document_distance.cc

profile:
	g++ -Wall -pg -c document_distance_log_scale.cc
	g++ -Wall -pg -o document_distance_profile document_distance_log_scale.o
	./document_distance_profile /home/nkd/Desktop/10-COURSES/6.006-intro-to-algorithms/spring10/source/lec01/data/t8.shakespeare.txt  /home/nkd/Desktop/10-COURSES/6.006-intro-to-algorithms/spring10/source/lec01/data/t5.churchill.txt
	gprof ./document_distance_profile | less

test: all
	# Logarithmic Scaling
	./document_distance_log_scale data/t1.verne.txt data/t2.bobsey.txt
	./document_distance_log_scale /home/nkd/Desktop/10-COURSES/6.006-intro-to-algorithms/spring10/source/lec01/data/t8.shakespeare.txt  /home/nkd/Desktop/10-COURSES/6.006-intro-to-algorithms/spring10/source/lec01/data/t5.churchill.txt
	
clean:
	rm -f *~ a.out document_distance document_distance_log_scale document_distance_profile *.o gmon.out
