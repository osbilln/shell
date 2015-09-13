#!/bin/bash

if [[ "$1" = "-h" ]]; then

  echo "Usage: $0 START_DATE END_DATE"
  echo "       Dates are epected in YYYY-MM-DD format"

  exit

fi

START_DATE=$1

END_DATE=$2

FILENAME=orders_$1_$2

if [[ ! -f xml2csv.xsl ]]; then
  echo "Cannot find xml2csv.xsl in current directory, aborting"
  exit 1
fi

if [[ -f $FILENAME.csv ]]; then
  echo "$FILENAME.csv already exists, aborting"
  exit 2
fi

if [[ -f $FILENAME.xml ]]; then
  echo "$FILENAME.xml already exists, aborting"
  exit 3
fi


curl --ntlm -u Naehas:N@3h@s123 http://service.thecomcaststore.com/kmstore/cs_naehas_webservices.asmx/GetNaehasOrderDetailsByDate?StartDate=$START_DATE\&EndDate=$END_DATE > $FILENAME.xml

xsltproc -o $FILENAME.csv xml2csv.xsl $FILENAME.xml

if [[ $? != 0 ]]; then
  echo "xsltproc failed, csv may not be correct or may be missing"
  exit 4
fi

sed -i -e '1,$ s/\"PHONE2\"[A-Z\",0-9_]*/\"PHONE2\",\"CUST1_NAME\",\"CUST1_VALUE\",\"CUST2_NAME\",\"CUST2_VALUE\",\"CUST3_NAME\",\"CUST3_VALUE\",\"CUST4_NAME\",\"CUST4_VALUE\",\"CUST5_NAME\",\"CUST5_VALUE\",\"CUST6_NAME\",\"CUST6_VALUE\",\"CUST7_NAME\",\"CUST7_VALUE\",\"CUST8_NAME\",\"CUST8_VALUE\",\"CUST9_NAME\",\"CUST9_VALUE\",\"CUST10_NAME\",\"CUST10_VALUE\",\"CUST11_NAME\",\"CUST11_VALUE\",\"CUST12_NAME\",\"CUST12_VALUE\",\"CUST13_NAME\",\"CUST13_VALUE\",\"CUST14_NAME\",\"CUST14_VALUE\",\"CUST15_NAME\",\"CUST15_VALUE\"/g' $FILENAME.csv

