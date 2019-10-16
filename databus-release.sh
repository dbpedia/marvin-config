#!/bin/bash

# get all variables and functions
source functions.sh


##################
# Setup and clone pom files
#################

# fails if folder exists
git clone "https://github.com/dbpedia/databus-maven-plugin.git" $DATABUSDIR 
cd $DATABUSDIR
git pull 

# copy 


# deploy 
cd $DATABUSDIR;
mvn versions:set -DnewVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1);

RELEASEPUBLISHER="https://vehnem.github.io/webid.ttl#this";
RELEASEPACKAGEDIR="/data/extraction/release/\${project.groupId}/\${project.artifactId}";
RELEASEDOWNLOADURL="http://dbpedia-generic.tib.eu/release/\${project.groupId}/\${project.artifactId}/\${project.version}/";
RELEASELABELPREFIX="(pre-release)";
RELEASECOMMENTPREFIX="(MARVIN is the DBpedia bot, that runs the DBpedia Information Extraction Framework (DIEF) and releases the data as is, i.e. unparsed, unsorted, not redirected for debugging the software. After its releases, data is cleaned and persisted under the dbpedia account.)";

>&2 mvn clean deploy -Ddatabus.publisher="$RELEASEPUBLISHER" -Ddatabus.packageDirectory="$RELEASEPACKAGEDIR" -Ddatabus.downloadUrlPath="$RELEASEDOWNLOADURL" -Ddatabus.labelPrefix="$RELEASELABELPREFIX" -Ddatabus.commentPrefix="$RELEASECOMMENTPREFIX";
 

