#!/bin/bash
echo "#*********************************"
echo "#Start server"
echo "#*********************************"
SERVER_SIZE=$1
IMAGE_ID=$2
DURATION_MINS=$3
USER_NAME=$4
KEY_NAME=$5
SECURITY_GROUP=$6
SUBNET=$7
TUNNEL_KEY=$8
PERF_KEY=$9
JUMP_IP=${10}
aws ec2 run-instances --instance-type "${SERVER_SIZE}" --key-name ${KEY_NAME} --subnet-id ${SUBNET} --image-id ${IMAGE_ID} --associate-public-ip-address --security-group-ids ${SECURITY_GROUP} > machine_setup.txt
#Get instance ID
cat machine_setup.txt | jq -r '.Instances[].InstanceId' > instance_id.txt
cat machine_setup.txt | jq -r '..|.PrivateIpAddress? //empty' | head -1 > private_ip.txt
#cat machine_setup.txt
instance_id=`cat instance_id.txt`
private_ip=`cat private_ip.txt`
#Add name tag to server
aws ec2 create-tags --resources ${instance_id} --tags Key="Name",Value="performance-load-test-$(date +%d/%m/%Y-%H:%M:%S)"
#Loop to wait till public IP address allocated
while [ -z "${public_ip}" ]
  do 
  aws ec2 describe-instances --instance-ids ${instance_id} > machine_post.txt
  cat machine_post.txt | jq -r '..|.PublicIp? //empty' > public_ip.txt
  public_ip=`head -n 1 public_ip.txt`
  echo "sleep waiting for public IP"
  sleep 5
done
echo "IP Address: ${public_ip}"
echo "Private IP Address: ${private_ip}"
echo "${public_ip}" > public_ip.txt
echo "jump ip = ${JUMP_IP}"

ssh -L 1235:${private_ip}:22 -i ${TUNNEL_KEY} andrew.holden@${JUMP_IP} -Nf
echo "Tunnel opened"
   
#Wait till machine can be SSH'd into
until ssh -i ./${PERF_KEY} -o StrictHostKeyChecking=no  -p 1235 ${USER_NAME}@localhost "ifconfig"
do
  echo "Server is not yet available. Trying again in 5 seconds..."
  sleep 5
done
echo "Server ${public_ip} is now available. Proceeding with script."
ssh -i ./${PERF_KEY} -o StrictHostKeyChecking=no  -p 1235 ${USER_NAME}@localhost "touch /tmp/helloworld.txt"
#Setup Suicide pill
ssh -i ./${PERF_KEY} -o StrictHostKeyChecking=no  -p 1235 ${USER_NAME}@localhost "sudo /sbin/shutdown -h +${DURATION_MINS}"
