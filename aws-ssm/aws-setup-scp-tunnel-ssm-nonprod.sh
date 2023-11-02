#!/bin/bash
mkdir ~/.ssh
#SSH over Session Manager
echo "host i-* mi-*" > ~/.ssh/config    
echo "ProxyCommand sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"" >> ~/.ssh/config
sudo chmod 700 ~
sudo chmod 600 nonprod.key
sudo chmod 700 ~/.ssh
sudo mv nonprod.key ~/.ssh/nonprod.key
