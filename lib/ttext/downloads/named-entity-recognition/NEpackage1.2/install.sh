#/bin/sh



echo "Installing NE package.  If you have problems installing this package, "
echo "read the README file included in this directory for details on using "
echo "the configure.pl script."

echo "Calling configure.pl for minimal installation changes..."

./configure.pl basic

echo "Compiling FEX..."

cd fex

make SERVER=1

cp fex fex_ne_server

echo "Compiling SNoW..."

cd ../snow/

make SERVER=1

cp snow snow_ne_server

echo "Compiling inference module..."

cd ../cscl

./makeit.sh

cd ..

echo "done."



