#!/bin/bash

echo "LC_ALL=en_US.UTF-8"
export LC_ALL=en_US.UTF-8


#######################
# include all functions and path variables
#######################
source functions.sh


#################
#check argument
#################
GROUP=$1

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ] && [ "$GROUP" != "sparktestgeneric" ] && [ "$GROUP" != "text" ]  || [ -z "$GROUP" ]
then
    echo "$HELP"
    exit 1
fi




#######################
# RUN (requires setup-dief.sh)
#######################

echo "DOWNLOAD ONTOLOGY AND MAPPINGS"
cd $DIEFDIR/core
../run download-ontology &>  $LOGDIR/downloadOntology.log
../run download-mappings &>  $LOGDIR/downloadMappings.log

echo "DOWNLOAD WIKIDUMPS"
cd $DIEFDIR/dump
../run download $CONFIGDIR/download.$GROUP.properties &>  $LOGDIR/downloadWikidumps.log 


echo "EXTRACT"
extractDumps &>  $LOGDIR/extraction.log;

echo "POST-PROCESSING"
postProcessing 2> $LOGDIR/postProcessing.log;


# CLEANUP
archiveLogFiles;
