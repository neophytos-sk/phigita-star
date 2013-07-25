#!/bin/sh
SECONDS=`date +%s`
curl -F upload_file=@$1 "http://ada:8001/ooo-converter/index?input_format=${3}&output_format=${4}&t=${SECONDS}" --output $2
