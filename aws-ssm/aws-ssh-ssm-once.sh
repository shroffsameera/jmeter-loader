#!/bin/bash

INSTANCE_ID=$1
CMD_ID=$2

while true
do
  aws ssm get-command-invocation --command-id ${CMD_ID} --instance-id ${INSTANCE_ID} --output json > output.txt
  cat output.txt
  echo $(cat output.txt | jq -r '.Status') > result.txt
  
 # Check if it's success or timeout
 if grep -qi 'Success\|TimedOut' result.txt; then
  echo "Found 'Success' or 'TimedOut' in the file."
  break
  # Your code to be triggered if 'success' or 'timeout' is found goes here
 else
  echo "No 'success' or 'timeout' found in the file."
  # Your code to be triggered if neither 'success' nor 'timeout' is found goes here
fi

done
