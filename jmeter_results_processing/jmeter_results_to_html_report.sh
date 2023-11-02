#!/bin/bash
#Generate JMeter HTML report
# Function to display debug messages
debug_msg() 
{
  if [ "$DEBUG" = "true" ]; then
    echo "DEBUG: $1"
  fi
}

DEBUG=$1
JMETER_LOCATION=$2
RESULTS_FILE=$3
RESULTS_FOLDER=$4
HTML_REPORT_NAME=$5
PROPERTY_FILE=$6

#Check if all arguments are provided
if [ $# -ne 6 ]; then
    echo "Usage: $0, Debug ["true", "false"], JMeter Location, Results file, Results folder to be created, HTML Report name to be created, jmeter properties file"
    exit 1
fi
# Check if the first argument is either 'true' or 'false' for debug mode
if [ "$1" != "true" ] && [ "$1" != "false" ]; then
  echo "Error: Debug argument must be 'true' or 'false'."
  exit 1
fi
#Check Jmeter Jar Exists
if [ -e $JMETER_LOCATION ]; then
echo ""
else
  echo "File not found: $JMETER_LOCATION"
  exit 1
fi
#Check Results File
if [ -e $RESULTS_FILE ]; then
echo ""
else
  echo "File not found: $RESULTS_FILE"
  exit 1
fi
if [ -d "$RESULTS_FOLDER" ]; then
  echo "Folder exists: $RESULTS_FOLDER"
  ls -al
  exit 1
else
echo ""
fi


debug_msg "*****DEBUG MODE ON ***** "
debug_msg "Starting Script $0"
debug_msg "JMeter location $2 - location of the Jmeter jar"
debug_msg "Results File $3 - Location of the csv file generate by a JMeter test"
debug_msg "Results Folder $4 - Folder that will be created to store the HTML report"
debug_msg "HTML Report name $5 - Name used for the zip file to store the HTML report"

if [ "$DEBUG" = "true" ]; then
	
	mkdir --verbose $RESULTS_FOLDER
	# Check the exit status of mkdir
	if [ $? -ne 0 ]; then
		echo "FAILED to create the directory: $RESULTS_FOLDER"
		exit 1
	else
		echo "Directory created successfully: $RESULTS_FOLDER"
	fi
	pwd
 	ls -al
  	ls -al ./Properties
	java -jar $JMETER_LOCATION -g $RESULTS_FILE -o $RESULTS_FOLDER -p $PROPERTY_FILE
	if [ $? -ne 0 ]; then
		echo "FAILED to Process Jmeter results file $RESULTS_FILE"
		exit 1
	else
		echo "Processed Jmeter results file $RESULTS_FILE"
	fi
	zip --verbose --recurse-paths $HTML_REPORT_NAME $RESULTS_FOLDER
	if [ $? -ne 0 ]; then
		echo "FAILED to created zip file $HTML_REPORT_NAME"
		exit 1
	else
		echo "Created zip file $HTML_REPORT_NAME"
	fi
	exit 0

else

	mkdir $RESULTS_FOLDER
	# Check the exit status of mkdir
	if [ $? -ne 0 ]; then
		echo "FAILED to create the directory: $RESULTS_FOLDER"
		exit 1
	else
		echo "Directory created successfully: $RESULTS_FOLDER"
	fi
	
	java -jar $JMETER_LOCATION -g $RESULTS_FILE -o $RESULTS_FOLDER -p $PROPERTY_FILE
	if [ $? -ne 0 ]; then
		echo "FAILED to Process Jmeter results file $RESULTS_FILE"
		exit 1
	else
		echo "Processed Jmeter results file $RESULTS_FILE"
	fi
	zip --quiet --recurse-paths $HTML_REPORT_NAME $RESULTS_FOLDER
	if [ $? -ne 0 ]; then
		echo "FAILED to created zip file $HTML_REPORT_NAME"
		exit 1
	else
		echo "Created zip file $HTML_REPORT_NAME"
	fi
	exit 0
fi
