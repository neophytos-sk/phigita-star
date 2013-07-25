
NAME = snow
VERSION = 3.1.6
#PROFILE = -pg -gstabs  # If you want to create performance profiles with gprof
CXXFLAGS = -O3 $(PROFILE)

# For Linux, uncomment the following, and see the note a few lines down next
# to the "LIBRARIES" variable.
# Tested on Linux 2.4.18-19.7.x with GCC v2.96
CXXFLAGS += -DLINUX

# If you do not have hash_map support, comment out the following line.
CXXFLAGS += -DHASH_MAP

ifdef SERVER
CXXFLAGS += -DSERVER_MODE_
#LIBRARIES = -lxnet -lpthread # You may need to remove xnet if using Linux.
LIBRARIES =  -lpthread # You may need to remove xnet if using Linux.
endif


###
# Dependencies
SOURCES = $(wildcard *.cpp)
SNOWOBJS = $(SOURCES:.cpp=.o)
CLOUDDEPS = Cloud.h TargetRank.h Winnow.h Perceptron.h NaiveBayes.h \
            LearningAlgorithm.h Target.h GlobalParams.h TargetIdSet.h \
            SnowTypes.h MinimalFeature.h
EXAMPLEDEPS = Example.h GlobalParams.h TargetIdSet.h SnowTypes.h
NAIVEBAYESDEPS = NaiveBayes.h LearningAlgorithm.h Target.h GlobalParams.h \
                 TargetIdSet.h SnowTypes.h MinimalFeature.h
NETWORKDEPS = Network.h TargetRank.h Winnow.h Perceptron.h NaiveBayes.h \
              LearningAlgorithm.h Target.h GlobalParams.h TargetIdSet.h \
              SnowTypes.h MinimalFeature.h
PERCEPTRONDEPS = Perceptron.h LearningAlgorithm.h Target.h GlobalParams.h \
                 TargetIdSet.h SnowTypes.h MinimalFeature.h
SNOWDEPS = Usage.h GlobalParams.h SnowParam.h Cloud.h Network.h Example.h \
           SendReceive.h
SNOWPARAMDEPS = SnowParam.h GlobalParams.h TargetIdSet.h SnowTypes.h
TARGETDEPS = Target.h LearningAlgorithm.h GlobalParams.h TargetIdSet.h \
             Winnow.h Perceptron.h NaiveBayes.h SnowTypes.h MinimalFeature.h
TARGETIDSETDEPS = TargetIdSet.h SnowTypes.h
TARGETRANKDEPS = TargetRank.h GlobalParams.h TargetIdSet.h SnowTypes.h
WINNOWDEPS = Winnow.h LearningAlgorithm.h Target.h GlobalParams.h \
             TargetIdSet.h SnowTypes.h MinimalFeature.h
###


###
# Build rules
$(NAME) : $(SNOWOBJS)
	$(CXX) $(PROFILE) -o $(NAME) $(SNOWOBJS) $(LIBRARIES)

%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $<

Cloud.o : $(CLOUDDEPS)
Example.o : $(EXAMPLEDEPS)
NaiveBayes.o : $(NAIVEBAYESDEPS)
Network.o : $(NETWORKDEPS)
Perceptron.o : $(PERCEPTRONDEPS)
Snow.o : $(SNOWDEPS)
SnowParam.o : $(SNOWPARAMDEPS)
Target.o : $(TARGETDEPS)
TargetIdSet.o : $(TARGETIDSETDEPS)
TargetRank.o : $(TARGETRANKDEPS)
Winnow.o : $(WINNOWDEPS)
###


###
# Utility rules
.PHONY : clean dist

clean: 
	-rm -f core gmon.out $(SNOWOBJS) $(NAME)


EXTRAS = Makefile getopt.c 0README revisions.txt \
         booleanexample/booleantest.snow booleanexample/one_target.arch \
         booleanexample/one_target_train.snow booleanexample/run.bat \
         booleanexample/run.sh booleanexample/two_targets.arch \
         booleanexample/two_targets_train.snow \
         booleanexample/conjunction_generator.pl \
         booleanexample/disjunction_generator.pl \
         tutorial/example_client.pl tutorial/archfile tutorial/testdata.snow \
         tutorial/traindata.snow tutorial/tutorial.bat tutorial/tutorial.sh \
         tutorial/Getopt/Declare.pm

dist : ../SNoW_v$(VERSION).tar.gz

../SNoW_v$(VERSION).tar.gz : $(SOURCES) *.h $(EXTRAS)
	cd ..; gtar zcf $(@F) $(^:%=$(notdir $(PWD))/%)
###

