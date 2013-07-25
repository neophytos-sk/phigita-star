#!/bin/sh
#
# Script to generate an HTML table of stats on standard output, generated
# from the MySQL table maintained by mailstats.sh.
#
# This script requires the MySQL command-line client, `mysql'. It may need
# to run under bash, rather than Bourne shell; this has not been tested.
#
# Fill in the MYSQL* variables to make this script work, and alter DAYS
# (number of days in the past to start from), HOURDIV (number of hours
# between rows), and BARLEN (pixel width of bar graph) as appropriate.
#
# Copyright 2007 Andrew Wood, distributed under the Artistic License.
#

MYSQLUSER=
MYSQLPASS=
MYSQLDB=
MYSQLTABLE=spamlog

DAYS=14
HOURDIV=24
BARLEN=300

# Remove this next line to enable this script!
echo "Please read this script first, copy it, THEN run it."; exit 1

TOTALS=\
'  COUNT(IF(type="SPAM",1,NULL)) AS spam,
   COUNT(IF(type="SPAM-BOUNCE",1,NULL)) AS spambounce,
   COUNT(IF(type="SPAM-REPLY",1,NULL)) AS spamreply,
   COUNT(IF(type="DELIVERED",1,NULL)) AS delivered,
   COUNT(IF(type="RETRAIN-SPAM",1,NULL)) AS retrainspam,
   COUNT(IF(type="RETRAIN-NONSPAM",1,NULL)) AS retrainnonspam'


function graph_row () {
	local VAL COL NAME MAX BARLEN WIDTH

	VAL="$1"
	COL="$2"
	NAME="$3"
	MAX="$4"
	BARLEN="$5"

	WIDTH=$[$[$VAL * $BARLEN] / $MAX]
	[ $WIDTH -lt 0 ] && WIDTH=0

	echo '<tr><td><table border="0" cellspacing="0" cellpadding="0">'

	if [ $WIDTH -lt 1 ]; then
		echo '<tr><td style="font-size: 6px;"'
	else
		echo '<tr><td style="background-color: #'"$COL"'; font-size: 6px;"'
		echo "width=\"$WIDTH\""
	fi
	echo ">&nbsp;</td>"

	if [ $[$ROWNUM % 10] -eq 1 ]; then
		echo "<td width=\"$[$BARLEN-$WIDTH]\" align=\"right\""
		echo "style=\"font-size: 6px;\">$NAME</td>"
	fi

	echo '</tr>'

	echo '</table></td></tr>'
}


export BARLEN
export HOURDIV

MAX=`mysql -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB -B -N -e \
  'SELECT '"$TOTALS"'
  FROM '"$MYSQLTABLE"'
  WHERE stamp >= DATE_SUB(FROM_DAYS(TO_DAYS(NOW())), INTERVAL '"$DAYS"' DAY)
  GROUP BY
  DATE_FORMAT(stamp,"%Y-%m-%d"),
  '"$HOURDIV"'*FLOOR(EXTRACT(HOUR FROM stamp)/'"$HOURDIV"')' \
| ( while read ROWS ROWSB ROWSR ROWD ROWRS ROWRN; do
	SPAM=$[$[$ROWS-$ROWSR]+$ROWRS]
	FALSENEG=$ROWRS
	NONSPAM=$[$[$ROWD+$ROWRN]-$ROWRS]
	FALSEPOS=$ROWSR
  	echo $SPAM
  	echo $FALSENEG
  	echo $NONSPAM
  	echo $FALSEPOS
  done ) \
| sort -n \
| tail -n 1`

[ $MAX -lt 1 ] && MAX=1
export MAX

mysql -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB -B -N -e \
  'SELECT DATE_FORMAT(stamp,"%Y-%m-%d") AS date,
  '"$HOURDIV"'*FLOOR(EXTRACT(HOUR FROM stamp)/'"$HOURDIV"') AS hour,
  '"$TOTALS"'
  FROM '"$MYSQLTABLE"'
  WHERE stamp >= DATE_SUB(FROM_DAYS(TO_DAYS(NOW())), INTERVAL '"$DAYS"' DAY)
  GROUP BY date,hour' \
| (
echo '<table class="spamlog" border="0" cellpadding="2" cellspacing="0">'
echo '<tr>'
echo '<th align="right">Date</th>'
[ $HOURDIV -lt 24 ] && echo '<th align="right">Time</th>'
echo '<th align="right" class="firstval"><span title="Spam (JMBA replied)">S</span></th>'
echo '<th align="right" class="val"><span title="JMBA bounced">SB</span></th>'
echo '<th align="right" class="val"><span title="JMBA returned">SR</span></th>'
echo '<th align="right" class="val"><span title="Delivered">D</span></th>'
echo '<th align="right" class="val"><span title="Retrain (spam)">RS</span></th>'
echo '<th align="right" class="val"><span title="Retrain (nonspam)">RN</span></th>'
echo '<th>&nbsp;</th>'
echo '</tr>'
PREVDATE=""
ROWNUM=0
while read DATE TIME ROWS ROWSB ROWSR ROWD ROWRS ROWRN; do

	SPAM=$[$[$ROWS-$ROWSR]+$ROWRS]
	FALSENEG=$ROWRS
	NONSPAM=$[$[$ROWD+$ROWRN]-$ROWRS]
	FALSEPOS=$ROWSR

	ROWNUM=$[1+$ROWNUM]

	if [ "$DATE" = "$PREVDATE" ]; then
		echo '<tr>'
		echo '<td align="right" valign="top">&nbsp;</td>'
	else
		echo '<tr class="newdate">'
		echo "<td align=\"right\" valign=\"top\">$DATE</td>"
	fi
	PREVDATE=$DATE
	[ $HOURDIV -lt 24 ] \
	&& echo "<td align=\"right\" valign=\"top\">$TIME:00</td>"

	FIRSTVAL=1
	for VAL in $ROWS $ROWSB $ROWSR $ROWD $ROWRS $ROWRN; do
		C=val
		[ $FIRSTVAL = 1 ] && C=firstval
		FIRSTVAL=0
		echo "<td align=\"right\" valign=\"top\" class=\"$C\">$VAL</td>"
	done

	echo '<td><table border="0" cellspacing="0" cellpadding="0">'

	graph_row $NONSPAM '080' 'Non-spam' $MAX $BARLEN
	graph_row $FALSEPOS '800' 'Non-spam falsely marked as spam' $MAX $BARLEN
	graph_row $SPAM '088' 'Spam' $MAX $BARLEN
	graph_row $FALSENEG '008' 'Spam that slipped through' $MAX $BARLEN

	echo '</table></td>'

	echo '</tr>'
done
echo '</table>'
)

# EOF
