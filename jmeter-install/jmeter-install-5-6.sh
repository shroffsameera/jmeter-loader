#!/bin/bash

#Shell Script to download Jmeter and useful Plugins
echo"###################################Check Java################################"
#Check the Java version
if type -p java> /dev/null; then
   echo "" >/dev/null 2>&1
else
   echo "Java is not installed!-EXITING"
   #exit 1
fi 

echo "################################Get JMETER##################################"
wget -g https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.2.zip

echo "###############################UNZIP Jmeter################################"
if [ -e apache-jmeter-5.6.2.zip ]; then
    unzip apache-jmeter-5.6.2.zip >/dev/null 2&1
    sudo rm apache-jmeter-5.6.2.zip
else 
    echo "apache-jmeter-5.6.2.zip File not FOund!- EXITING"
    exit 1
fi

#get command runner
echo "########################################GET COMMAND Runner######################"
wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.3/cmdrunner-2.3.jar --directory-prefix ./apache-jmeter-5.6.2/lib >/dev/null 2>&1

#Get Plugins Manager
echo "######################################GET Plugins Manager########################"
wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.8/jmeter-plugins-manager-1.8.jar --directory-prefix ./apache-jmeter-5.6.2/lib/ext >/dev/null 2>&1
java -cp ./apache-jmeter-5.6.2/lib/ext/jmeter-plugins-manager-1.8.jar org.jmeterplugins.repository.PluginManagerCMDInstaller >/dev/null 2>&1



#Install plugins except licensed plugins
echo "#################################### INSTALLING PLUGINS###########################"
./apache-jmeter-5.6.2/bin/PluginsManagerCMD.sh install \
jpgc-functions,\
jpgc-cmd,\
jpgc-graphs-basic,\
jpgc-graphs-additional,\
jpgc-graphs-dist,\
jpgc-graphs-vs,\
jpgc-ggl,\
jpgc-graphs-composite,\
tilln-junit,\
jpgc-csl,\
jpgc-mergeresults,\
jpgc-ffw,\
jpgc-casutg,\
jpgc-tst,\
jpgc-dummy,\
bzm-parallel,\
jpgc-autostop,\
jpgc-synthesis,\
bzm-random-csv >/dev/null 2>&1

#Can add backend listeners like datadog, elastic search for backend processing. 

echo "#########################################JMETER VERSION##################################"
#Print Jmeter version
java -jar ./apache-jmeter-5.6.2/bin/ApacheJMeter.jar -v
sudo rm jmeter.log > /dev/null
echo "######################################FINISHED###########################################"
exit 0




