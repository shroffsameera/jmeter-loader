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
RESULTS_FOLDER=$4
WIDTH=$5
HEIGHT=$6
GRANULARITY=$7

#Check if all arguments are provided
if [ $# -ne 7 ]; then
    echo "Usage: $0, Debug ["true", "false"], JMeter Command runner, Results file csv input, "
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

debug_msg "*****DEBUG MODE ON ***** "
debug_msg "Starting Script $0"
debug_msg "Jmeter Command Runner location $JMETER_CMD_RUNNER_LOCATION - location of the Jmeter cmd runner"
debug_msg "Results File $RESULTS_FILE- Location of the csv file generate by a JMeter test"
debug_msg "Results Folder $RESULTS_FOLDER - Folder that will be created to store the HTML report"
debug_msg "Width: $WIDTH - Height: $HEIGHT - Granularity: $GRANULARITY - Graph Settings"

if [ "${0##*/}" = "bash" ]; then
    echo "Running in Bash"
elif [ "${0##*/}" = "sh" ]; then
    echo "Running in sh"
else
    echo "Unknown shell"
fi

# Declare an array containing the list of items
list=("ResponseTimesOverTime" "ThreadsStateOverTime" "HitsPerSecond" "LatenciesOverTime" "ResponseCodesPerSecond" "ResponseTimesDistribution" "ResponseTimesPercentiles" "ThroughputVsThreads" "TimesVsThreads")

# Initialize the counter variable
j=1
# Iterate through the array
for item in "${list[@]}"
do
    java -jar $JMETER_CMD_RUNNER_LOCATION --tool Reporter --generate-png $RESULTS_FOLDER/Report-Image-$item.png --input-jtl $RESULTS_FILE --plugin-type $item --width $WIDTH --height $HEIGHT --granulation $GRANULARITY
    # Increment the counter for the next iteration
    ((j++))
done
zip -r images.zip $RESULTS_FOLDER/*.png
