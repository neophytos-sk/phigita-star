mkdir /opt/sbt/0.12.2
mkdir /opt/sbt/0.13.1

wget -O /opt/sbt/0.12.2/sbt-launch.jar http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.12.2/sbt-launch.jar
wget -O /opt/sbt/0.13.1/sbt-launch.jar http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.1/sbt-launch.jar
ln -sf /opt/sbt/0.13.1/sbt-launch.jar /opt/sbt/sbt-launch.js

