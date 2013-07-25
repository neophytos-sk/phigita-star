#!/bin/sh
convert  line1/* +append line1.png
#convert  line2/*.png +append line2.png
#convert  line1.png -append test.png

convert line1.png test.gif
rm ~/www/lib/xo-1.0.0/resources/images/ed-buttons-main.*
#mv test.png ~/www/lib/xo-1.0.0/resources/images/ed-buttons-main.png
mv test.gif ~/www/lib/xo-1.0.0/resources/images/ed-buttons-main.gif
rm line*.png
