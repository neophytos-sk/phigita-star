CLASS_DIR="classes"

all: SpamLord.class Submit.class

SpamLord.class : SpamLord.java
	mkdir -p classes
	javac -d classes SpamLord.java

Submit.class : Submit.java Base64.java
	mkdir -p classes
	javac -cp "json-simple-1.1.1.jar:." -d classes Submit.java

run : SpamLord.class
	java -cp classes/ SpamLord ../data/dev ../data/devGOLD

submit : Submit.class SpamLord.class
	java -cp "json-simple-1.1.1.jar:classes/" Submit

clean :
	rm -rf classes/
