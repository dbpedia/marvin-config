#!/bin/bash

HELP="usage: 
--group={test|generic|mappings|wikidata} [--databus-deploy]

description:
--group={test|generic|mappings|wikidata} : required
	selects download.\$GROUP.properties and extraction.\$GROUP.properties from extractionConfig dir
	Some exceptions are hard coded like 'extraction.generic.en.properties'
"

#######################
# include all functions and path variables
#######################
source functions.sh


#################
#check arguments
#################
GROUP=""
DATABUSDEPLOY=false
SKIPDIEFINSTALL=false

for i in "$@"
do
case $i in
    -g=*|--group=*)
    GROUP="${i#*=}"
    shift
    ;;
    --databus-deploy)
    DATABUSDEPLOY=true
    shift
    ;;
    --skip-dief-install)
    SKIPDIEFINSTALL=true
    shift
    ;;
    -h|--help)
    echo -e $HELP
    exit 1
    shift
    ;;
    *)
    echo "unknown option: $i"
    echo "$HELP"
    exit 1
    ;;
esac
done

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ] || [ -z "$GROUP" ]
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

# RELEASE 
#databusRelease 2> $LOGDIR/databusDeploy.log

# CLEANUP
archiveLogFiles;
