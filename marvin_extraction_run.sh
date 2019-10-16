#!/bin/bash



#######################
# include all functions and path variables
#######################
source functions.sh


#################
#check argument
#################
GROUP=$1

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ]  && [ "$GROUP" != "text" ]  || [ -z "$GROUP" ]
then
    echo "$HELP"
    exit 1
fi




#######################
# RUN (requires setup-dief.sh)
#######################

# DOWNLOAD ONTOLOGY and MAPPINGS
cd $DIEFDIR/core
../run download-ontology &> $LOGDIR/downloadOntology.log
../run download-mappings &> $LOGDIR/downloadMappings.log

# DOWNLOAD WIKIDUMPS
cd $DIEFDIR/dump
../run download $CONFIGDIR/download.$GROUP.properties &> $LOGDIR/downloadWikidumps.log 

# EXTRACT
extractDumps &> $LOGDIR/extraction.log;

# POST-PROCESSING
postProcessing 2> $LOGDIR/postProcessing.log;


# CLEANUP
archiveLogFiles;
