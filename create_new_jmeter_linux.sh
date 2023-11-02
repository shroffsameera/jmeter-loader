#!/bin/bash
#Create the AWS instance with your own private key, then run this script

# Define variables
username="perf"
home_dir="/home/$username"
ssh_dir="$home_dir/.ssh"
authorized_keys="$ssh_dir/authorized_keys"
private_key="$ssh_dir/id_rsa"
public_key="$ssh_dir/id_rsa.pub"

# Create user
sudo adduser "$username"

# Set up SSH directory and keys
sudo mkdir -p "$ssh_dir"
sudo mkdir $home_dir/performance_testing
sudo mkdir $home_dir/results

sudo touch "$authorized_keys"
sudo ssh-keygen -t rsa -b 4096 -C "$username" -f "$private_key" -N ""
sudo chmod 777 -R "$home_dir"
sudo cat "$public_key" >> "$authorized_keys"

# Set ownership and permissions
sudo chmod 600 "$private_key" "$public_key"
sudo chmod 600 "$authorized_keys"
sudo chmod 700 "$ssh_dir"
sudo chown -R "$username:$username" "$home_dir"
sudo chmod 700 "$home_dir"

#Install Basics
#sudo yum update -y; sudo yum install unzip -y; sudo amazon-linux-extras install java-openjdk11 -y
sudo yum update -y; sudo yum install unzip -y; sudo yum install java-11-amazon-corretto-headless -y >/dev/null 2>&1

#Get basic Jmeter
sudo wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.zip --directory-prefix /tmp >/dev/null 2>&1
#Unzip JMeter
sudo unzip /tmp/apache-jmeter-5.5.zip -d $home_dir >/dev/null 2>&1

#Get command runner
echo "######################GET COMMAND RUNNER###############"
sudo wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.3/cmdrunner-2.3.jar --directory-prefix $home_dir/apache-jmeter-5.5/lib >/dev/null 2>&1
#Get Plugins manager
echo "######################GET PLUGINS MANAGER##############"
sudo wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.8/jmeter-plugins-manager-1.8.jar --directory-prefix $home_dir/apache-jmeter-5.5/lib/ext >/dev/null 2>&1
sudo java -cp $home_dir/apache-jmeter-5.5/lib/ext/jmeter-plugins-manager-1.8.jar org.jmeterplugins.repository.PluginManagerCMDInstaller >/dev/null 2>&1
#Install plugins except licensed plugins
echo "######################INSTALLING PLUGINS###############"
#sudo $home_dir/apache-jmeter-5.5/bin/PluginsManagerCMD.sh install-all-except  ulp-jmeter-autocorrelator-plugin,ulp-jmeter-gwt-plugin,ulp-jmeter-videostreaming-plugin
sudo $home_dir ./apache-jmeter-5.5/bin/PluginsManagerCMD.sh install \
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

echo "######################JMETER VERSION###################"
#Print JMeter Version
sudo java -jar $home_dir/apache-jmeter-5.5/bin/ApacheJMeter.jar -v

#Pass ownership to perf
sudo chown -R $username $home_dir

##########################
Setup to allow perf to run shutdown, this is a sudo command
##########################
echo "perf ALL=(root) NOPASSWD: /sbin/shutdown" > /tmp/shutdown
sudo mv /tmp/shutdown /etc/sudoers.d/shutdown
sudo chown root:root /etc/sudoers.d/shutdown
sudo chmod 440 /etc/sudoers.d/shutdown

#
#COPY PERF USER ID_RSA PRIVATE KEY TO BE USED TO ACCESS THIS IMAGE
#Preferably remove the ID_RSA private key - REMEMBER TO COPY IT FIRST
#

#**************************************************
#**************************************************
#AT 6am THIS WILL SCHEDULE THE MACHINETO STOP EVERY DAY AT 9AM!!!!!!!
#**************************************************
#**************************************************
sudo su root
echo "* 06 * * * root /usr/sbin/shutdown -h +180" >> /etc/crontab
#Exit from root
exit


#####################
#Really useful list of Plugins
#####################
#########FUNCTIONS#########
# jpgc-functions - https://jmeter-plugins.org/wiki/Functions/ - Extended functions library
#########GRAPHS#########
# jpgc-cmd - https://jmeter-plugins.org/wiki/JMeterPluginsCMD/ - Graph Plotter, Installed with plugins manager
# jpgc-graphs-basic - https://jmeter-plugins.org/wiki/ResponseTimesOverTime/ - Average Response Time, Active Threads, Successful/Failed Transactions
# jpgc-graphs-additional - https://jmeter-plugins.org/wiki/ResponseCodesPerSecond/  - Response Codes, Bytes Throughput, Connect Times, Latency, Hits/s
# jpgc-graphs-dist - https://jmeter-plugins.org/wiki/RespTimesDistribution/ - Response Times Distribution, Response Times Percentiles
# jpgc-graphs-vs - https://jmeter-plugins.org/wiki/ResponseTimesVsThreads/ - Hits/s vs Active Threads, Avg Response Time vs Active Threads
# jpgc-ggl - https://jmeter-plugins.org/wiki/GraphsGeneratorListener/ - Generate graphs at end of test
# jpgc-graphs-composite - https://jmeter-plugins.org/wiki/CompositeGraph/ - Graph that is able to show several other graphs data in single place

#########REPORTING##########
# tilln-junit - https://github.com/tilln/jmeter-junit-reporter - Response time percentiles (any), Maximum and minimum response time, Response time average and standard deviation, Sample error rate,Total number of samples,Custom metrics
# jpgc-csl - https://jmeter-plugins.org/wiki/ConsoleStatusLogger/ - Small listener that prints each second a line with runtime stats into console
# jpgc-mergeresults - https://jmeter-plugins.org/wiki/MergeResults/ - Merge Results is a tool to merge files of results (to simplify the comparison of two or more load tests).
# jmeter-datadog-backend-listener - https://github.com/DataDog/jmeter-datadog-backend-listener/ - Send JMeter test results to Datadog
# jmeter-dynatrace-backend-listener - https://github.com/dynatrace-oss/jmeter-dynatrace-plugin - Send JMeter test results to Dynatrace
# jmeter.backendlistener.elasticsearch - https://github.com/delirius325/jmeter-elasticsearch-backend-listener - Apache JMeter plugin for sending sample results to an ElasticSearch engine.
# jpgc-ffw - https://jmeter-plugins.org/wiki/FlexibleFileWriter/ - Flexible File Writer plugin allows writing test results in flexible format, specified via GUI.

#########THREAD GROUPS#########
# jpgc-casutg - https://jmeter-plugins.org/wiki/ConcurrencyThreadGroup/ - Custom Thread Groups
# jpgc-tst - https://jmeter-plugins.org/wiki/ThroughputShapingTimer/ - A plugin to set desired hits/s (RPS) schedule

#########SAMPLERS#########
# jpgc-dummy - https://jmeter-plugins.org/wiki/DummySampler/ - Dummy for debugging etc
# mqmeter - https://github.com/JoseLuisSR/mqmeter
# bzm-http2 - https://github.com/Blazemeter/jmeter-http2-plugin/blob/master/README.md - HTTP/2 protocol sampler
# bzm-rte - https://github.com/Blazemeter/RTEPlugin/blob/master/README.md - Support for RTE (remote terminal emulation), providing a recorder, sampler and config element to interact with remote terminal servers
# ssh-sampler - https://github.com/yciabaud/jmeter-ssh-sampler

#########DATA#########
# bzm-random-csv
# jpgc-csvars - https://jmeter-plugins.org/wiki/VariablesFromCSV/ - Config item to load one-line CSV file into JMeter variables on startup. Helps to have external configuration file for test plan.
# baolu-csv-data-file-config - https://github.com/LeeBaul/baolu-csv-data-file-config
# extended-csv-dataset-config - https://github.com/rollno748/Extended-csv-dataset-config#readme - Jmeter plugin to effectively manage CSV dataset like other enterprise industry standard tools.

#########TEST EXECUTION#########
# bzm-parallel - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/parallel/Parallel.md
# jpgc-autostop - https://jmeter-plugins.org/wiki/AutoStop/ - Ability to stop test based on runtime KPIs


#########RECORDING / SCRIPTING#########
# bzm-siebel - https://github.com/Blazemeter/CorrelationRecorder/blob/master/README.md - Correlation Recorder provides auto-correlation of variables at recording time

#########MONITORING#########
# jpgc-dbmon - https://jmeter-plugins.org/wiki/DbMon/ - DbMon lets you plot performance counters accessible via SQL when the test is running.
# jpgc-perfmon - https://jmeter-plugins.org/wiki/PerfMon/ - Allows collecting target server resource metrics. You need to start ServerAgent on a target machine.
# tilln-sshmon - https://github.com/tilln/jmeter-sshmon - Monitoring plugin for agentless collection and plotting of remote server metrics via SSH connections

# jpgc-esa - https://github.com/undera/jmeter-extract-success
# jpgc-filterresults - https://jmeter-plugins.org/wiki/FilterResultsTool/ - Often it's necessary to filter the results of a test to obtain a global vision with pages without all the urls that are declared in the html page.
# jpgc-sts - https://jmeter-plugins.org/wiki/HttpSimpleTableServer/ - The main idea is to use a tiny http server in JMeter Plugins to manage the dataset files with simple commands to get / add rows of data in files.
# jmeter.pack-listener - https://gitlab.com/testload/jmeter-listener/wikis/home - This JMeter Plugin allows to write load test data on-the-fly to ClickHouse (as well as InfluxDB, ElasticSearch, with additional feature: aggregation of Samplers)


############LOW PRIORITY#########################
# jpgc-standard - https://jmeter-plugins.org/ - Virtual package, select to install its dependencies
# tilln-wssecurity - https://github.com/tilln/jmeter-wssecurity - Digital signature, encryption, decryption, timestamp and username token for SOAP messages via Pre/Post-Processors that modify sampler payloads/responses.
# jpgc-xml - https://jmeter-plugins.org/wiki/XMLFormatPostProcessor- XML Format Post Processor
# jpgc-wsc - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/wsc/WeightedSwitchController.md - This controller takes the information about child elements and offers managing relative weights for them.
# websocket-sampler - https://github.com/maciejzaleski/JMeter-WebSocketSampler/wiki
# websocket-samplers -  https://bitbucket.org/pjtr/jmeter-websocket-samplers/overview
# jpgc-webdriver - https://github.com/undera/jmeter-plugins-webdriver - This plugin allows testing real browser behavior using Selenium/WebDriver technology
# ulp-observability-plugin - https://www.ubik-ingenierie.com/blog/ubik-load-pack-observability-plugin/ - This plugin allows you to monitor your JMeter CLI performance test from your favorite browser without having to start JMeter in GUI mode
# validate-thread-group - https://github.com/QAInsights/validate-thread-group - Adds Validation Thread Group option to the toolbar
# ulp-jmeter-autocorrelator-plugin - https://www.ubik-ingenierie.com/blog/ubikloadpack-autocorrelator-plugin-help/ - Plugin which provides the ability to easily load tests Vaadin, Oracle Siebel, Oracle PeopleSoft, Oracle Hyperion and Oracle JD-Edwards EntrepriseOne (JDE Eone) applications with Apache JMeter
# ulp-jmeter-gwt-plugin - https://www.ubik-ingenierie.com/blog/ubikloadpack-gwt-plugin-help/ - Plugin which provides the ability to easily script and performance test GWT based applications. 
# jpgc-plancheck - https://jmeter-plugins.org/wiki/TestPlanCheckTool/ - Small command line tool to check test plan consistency. Helps in automation of JMeter executions.
# jpgc-udp - https://jmeter-plugins.org/wiki/UDPRequest/ - This plugin adds UDP protocol support to JMeter. With this plugin you can load test DNS, NTP, TFTP, Boot servers and many-many other systems.
# jpgc-synthesis - https://jmeter-plugins.org/wiki/SynthesisReport/ - Synthesis Report is a mix between Summary Report and Aggregate Report
# tilln-retrier - https://github.com/tilln/jmeter-retrier - Post-Processor that retries failed samplers based on sample results (regex match of response code, data, headers or message).
# jmeter-prometheus - https://github.com/johrstrom/jmeter-prometheus-plugin - A Jmeter plugin to expose sampled metrics to an endpoint to be scraped by Prometheus.
# jpgc-redis - https://jmeter-plugins.org/wiki/RedisDataSet/ - Allows reading test data from Redis storage
# resultscomparator - https://github.com/rbourga/jmeter-plugins-2/blob/main/tools/resultscomparator/src/site/dat/wiki/ResultsComparator.wiki - Compares the results of two test runs using Cohen's d effect size.
# outlierdetector - https://github.com/rbourga/jmeter-plugins-2/blob/main/tools/outlierdetector/src/site/dat/wiki/RightTailOutlierDetection.wiki - A Jmeter plugin that detects and removes outliers in the right tail using Tukey fences.
# jpgc-rotating-listener - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/rotating-listener/RotatingListener.md - Rotating listener provides writing sequence of files, limited by number of samples per file.
# jpgc-prmctl - https://jmeter-plugins.org/wiki/ParameterizedController/ - A controller and sampler to help reuse modules with variables in the scope
# jpgc-pde - https://jmeter-plugins.org/wiki/PageDataExtractor/ - This graph will plot data extracted from page results (status, health pages, etc.).
# mqtt-xmeter - https://github.com/xmeter-net/mqtt-jmeter - connect, publish, subscribe and disconnect samplers
# mqtt-sampler
# jpgc-lockfile - https://jmeter-plugins.org/wiki/LockFile/ - Lock file allows you to set locks to prevent multiple JMeters from running on the same machine
# jmeter.backendlistener.kafka - https://github.com/rahulsinghai/jmeter-backend-listener-kafka/issues - Apache JMeter plugin for sending sample results to a Kafka server.
# kafkameter - https://github.com/rollno748/di-kafkameter#readme - Jmeter plugin to push/read events/messages to Kafka topics
# jpgc-json - https://jmeter-plugins.org/wiki/JSONPathExtractor/ - [Deprecated in favor of core JMeter 4.0+] Allows extracting values from JSON/YAML responses using JSONPath syntax. Also ships JSONPath Assertion.
# jmeter-grpc-request - https://github.com/zalopay-oss/jmeter-grpc-request - Send gRPC request
# jpgc-jmxmon - https://jmeter-plugins.org/wiki/JMXMon/ - JMXMon lets you plot JMX performance metrics over time when the test is running.
# jpgc-jms - https://jmeter-plugins.org/wiki/JMSSampler/  - end and receive messages between two or more clients, we have created a sampler which enables you to send and receive messages.
# jpgc-fifo - https://jmeter-plugins.org/wiki/InterThreadCommunication/ - Global string queues for inter-thread communication
# tilln-iso8583 - https://github.com/tilln/jmeter-iso8583 - Generate ISO-8583 financial transactions for testing of payment gateways and switches
# jpgc-hadoop - https://jmeter-plugins.org/wiki/HadoopSet/ - HBase Connection Config, HDFS Operations,Hadoop Job Tracker Sampler,HBase CRUD Sampler,HBase Scan Sampler,HBase Rowkey Sampler
# jpgc-httpraw  -https://jmeter-plugins.org/wiki/RawRequest/ - Low-level HTTP request, solves memory problem for huge file upload/download case. Also ships Raw Data Source preprocessor.
# tilln-formman - https://github.com/tilln/jmeter-formman - This plugin makes JMeter behave a little more like a browser: form fields are automatically populated with preselected values.
# jmeter-pubsub-sampler - https://github.com/rollno748/Jmeter-pubsub-sampler - Jmeter plugin to Publish and Subscribe Messages to GCP PubSub.
# jpgc-directory-listing - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/directory-listing/DirectoryListing.md - Directory listing config allows to set file path from source directory into jmeter-variable
# di-kafkameter - https://github.com/rollno748/di-kafkameter#readme - Jmeter plugin to push/read events/messages to Kafka topics
# custom-soap - https://github.com/spinning10/JMeterSoapSampler/wiki
# jpgc-xmpp - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/xmpp/XMPPSampler.md - Enables testing XMPP (Jabber) protocol servers
# blazemeter-debugger - https://github.com/Blazemeter/jmeter-debugger
# ulp-jmeter-videostreaming-plugin - https://www.ubik-ingenierie.com/blog/ubikloadpack-streaming-plugin-help/
# awsmeter - https://github.com/JoseLuisSR/awsmeter
# schema-assertion - https://github.com/yeshan333/ApacheJmeter_Schema_Assertion - Validate response field types based on JSON/YAML Schema
# apdexcalculator - https://github.com/rbourga/jmeter-plugins-2/blob/main/tools/apdexcalculator/src/site/dat/wiki/ApdexScoreCalculator.wiki - Calculates the Apdex score and rating of Samplers for a given satisfied threshold.
# jpgc-plugins-manager=1.8 - THe plugins manager
# jmeter-atakama-backend-listener-plugin - https://github.com/atakama/jmeter_plugin_backend_listener - This plugin aims to send jmeter metrics to Atakama Infrastructure
# jmeter-atakama-variabilization-plugin - https://github.com/atakama/jmeter_plugin_variabilization - Atakama Variabilization Plugin Variabilization plugin for jmeter: You can request a trial by following this link: https://ph-eval.atakama-technologies.com/downloadWebsite/index.php/product/show?id=1
# jmeter.backendlistener.azure - https://github.com/adrianmo/jmeter-backend-azure - Apache JMeter plugin that enables you to send test results to Azure Application Insights.
# bzm-jmeter-citrix-plugin - https://github.com/Blazemeter/CitrixPlugin/blob/master/README.md - Support for Citrix protocol (only available for Microsoft Windows)
# bzm-hls - https://github.com/Blazemeter/HLSPlugin/blob/master/README.md - HLS protocol sampler, enabling testing for streaming applications
# bzm-http2-legacy - https://github.com/Blazemeter/jmeter-http2-plugin/blob/LEGACY/README.md - This is a deprecated HTTP/2 plugin which allows to test the HTTP2 protocol in java 8
# jpgc-sense - https://github.com/Blazemeter/jmeter-bzm-plugins/blob/master/sense-uploader/BlazemeterPlugin.md - This is special plugin in for uploading results to BlazeMeter/BlazeMeter Sense during test running or immediately after test end
# netflix-cassandra - https://github.com/Netflix/CassJMeter/wiki
# couchbase - https://github.com/rollno748/JMeter-couchbase-sampler#readme - JMeter plugin to load test Couchbase DB
# yongfa365-jmeter-plugins - https://github.com/yongfa365/yongfa365-jmeter-plugins - 'Markdown Table Data-driven Controller' on GUI,like 'While Controller' but easier.'JsonPath Assertion' can assert elements sort 'Is Asc' or 'Is Desc' or 'All Match' or 'Any Match' or 'count between a and b''Console And Html Report' can gen beautiful html report and console report,It's useful for Je
