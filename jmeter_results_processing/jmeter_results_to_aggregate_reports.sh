#!/bin/bash
# Function to display debug messages
debug_msg() 
{
  if [ "$DEBUG" = "true" ]; then
    echo "DEBUG: $1"
  fi
}


DEBUG=$1
JMETER_CMD_RUNNER_LOCATION=$2
RESULTS_FILE=$3
AGGREGATE_CSV_OUTPUT_FILE=$4
AGGREGATE_HTML_OUTPUT_FILE=$5

#Check if all arguments are provided
if [ $# -ne 5 ]; then
    echo "Usage: $0, Debug ["true", "false"], JMeter Command runner, Results file csv input, Aggregate CSV Report output, Aggregate HTML Report, output"
    exit 1
fi

if [ "$1" != "true" ] && [ "$1" != "false" ]; then
  echo "Error: Debug argument must be 'true' or 'false'."
  exit 1
fi
#JMeter Command runner file exists
if [ -e $JMETER_CMD_RUNNER_LOCATION ]; then
  echo ""
else
  echo "File not found: $JMETER_CMD_RUNNER_LOCATION"
  exit 1
fi
#Check if data file exists
if [ -e $RESULTS_FILE ]; then
  echo ""
else
  echo "Date file not found: $RESULTS_FILE"
  exit 1
fi

#Generate Aggregate report - Done AFTER PNGs as a second CSV would confuse the Generate graphs on controller above
java -jar $JMETER_CMD_RUNNER_LOCATION --tool Reporter --input-jtl $RESULTS_FILE --Generate-csv $AGGREGATE_CSV_OUTPUT_FILE --plugin-type AggregateReport

html_table_open_tag="<table>" 
header=$(head -n 1 $AGGREGATE_CSV_OUTPUT_FILE | sed -e 's/^/<tr><th>/' -e 's/,/<\/th><th>/g' -e 's/$/<\/th><\/tr>/' | sed  's/\r//' | sed ':a;N;$!ba;s/\n//g')
data=$(tail -n +2 $AGGREGATE_CSV_OUTPUT_FILE | sed -e 's/^/<tr><td>/' -e 's/,/<\/td><td>/g' -e 's/$/<\/td><\/tr>/' | sed  's/\r//' | sed ':a;N;$!ba;s/\n//g') 
html_table_close_tag="</table>"
echo ${html_table_open_tag}${header}${data}${html_table_close_tag} > $AGGREGATE_HTML_OUTPUT_FILE
