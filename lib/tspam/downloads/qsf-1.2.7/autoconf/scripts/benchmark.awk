#!/bin/awk -f
/Backend type:/ { backend=$NF; }
/Counting messages/ { msgcount=$NF; }
/during training/ { tnext=1; }
/during classification/ { tnext=2; }
/Total time/ {
	if (tnext == 1) {
		time_train=$NF;
	} else {
		time_class=$NF;
	}
}
/Accuracy:/ {
	accuracy=$2;
	printf "%d %f\n", msgcount, time_train >>"benchmark-data-train-"backend;
	printf "%d %f\n", msgcount, time_class >>"benchmark-data-class-"backend;
	printf "%d %f\n", msgcount, accuracy >>"benchmark-data-accuracy-"backend;
}
# EOF
