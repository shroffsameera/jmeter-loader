#!/bin/bash
INSTANCE_ID=$1
CMD=$2

aws ssm send-command --document-name "AWS-RunShellScript" --parameters 'commands=["'"${CMD}"'"]' --targets "Key=instanceids,Values=${INSTANCE_ID}" --comment "echo Execute Test" > command.txt

echo "" > output.txt
wc output.txt

echo "Running cat command.txt"
cat command.txt
echo "Running cat output.txt"
cat output.txt

while true
do
  echo "Running cat output.txt within while loop"
  cat output.txt

  echo "Running aws ssm wait command-executed --command-id $(cat command.txt | jq -r '.Command.CommandId') --instance-id ${INSTANCE_ID} --output json || echo "fail" > output.txt"
  aws ssm wait command-executed --command-id $(cat command.txt | jq -r '.Command.CommandId') --instance-id ${INSTANCE_ID} --output json || echo "fail" > output.txt
  COUNT=$(awk 'length($0) < 3 {print $0}' "output.txt" | wc -l)
  wc output.txt

  echo "Running cat output.txt within while loop"
  cat output.txt

  echo "COUNT: $COUNT"
  # Check if there are any matching words
  if [ "$COUNT" -gt 0 ]; then
    echo "The file is not empty, will break"
    break
  else
    echo "The file contains 'fail'"
    echo "" > output.txt
  fi          
done
