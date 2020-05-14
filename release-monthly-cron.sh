#!/bin/bash

cd $(dirname $0);
source ./functions.sh;

#################
# check argument
#################
GROUP=$1;

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ] && [ "$GROUP" != "text" ] || [ -z "$GROUP" ]
then
    echo "$HELP";
    exit 1;
fi


#################
# MARVIN release
#################
cd $ROOT;

./marvin_extraction_run.sh $GROUP;
[ $GROUP = "generic" ] && ./marvin_extraction_run.sh $GROUP.en;

./databus-release.sh $GROUP;


#####################
# DBpedia re-release
#####################
cd $DATABUSDIR/dbpedia/$GROUP;

deriveVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1)

mvn -Ddatabus.deriveversion=$deriveVersion clean databus-derive:clone \
&& for i in `ls -d */` ; do cd $i ; mvn  clean -Pwebdav deploy ; cd .. ; done
