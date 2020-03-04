#!/bin/bash

# get all variables and functions
source functions.sh


#################
#check argument
#################
GROUP=$1

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ] && [ "$GROUP" != "text" ] || [ -z "$GROUP" ]
then
    echo "$HELP"
    exit 1
fi


##################
# Setup and clone pom files
#################

#/data/extraction/wikidumps/enwiki/20191001

git clone "https://github.com/dbpedia/databus-maven-plugin.git" $DATABUSDIR &>/dev/null
cd $DATABUSDIR
git pull

# copy
# iterate all .ttl.bz2 files
# uncomment for testing
for path in $(find "$EXTRACTIONBASEDIR" -name "*.ttl.bz2" | sort); do
   mapAndCopy $path
done

# deploy
cd $DATABUSDIR/dbpedia/$GROUP;
mvn versions:set -DnewVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1);

# get git commit link
GITHUBLINK="$(diefCommitLink)"

PUBLISHER="https://vehnem.github.io/webid.ttl#this";
# TODO marvin: shouldn't this be the web dir directly?
PACKAGEDIR="/data/extraction/release/\${project.groupId}/\${project.artifactId}";
DOWNLOADURL="http://dbpedia-$GROUP.tib.eu/release/\${project.groupId}/\${project.artifactId}/\${project.version}/";
LABELPREFIX="(pre-release) ";
# todo replace with markdown or html when supported by upload client
COMMENTPREFIX="(MARVIN is the DBpedia bot for monthly raw releases (unparsed, unsorted) for debugging the DIEF software. After its releases, data is cleaned and persisted under the dbpedia account. Commit: $GITHUBLINK) " ;

mvn clean deploy -Ddatabus.publisher="$PUBLISHER" -Ddatabus.packageDirectory="$PACKAGEDIR" -Ddatabus.downloadUrlPath="$DOWNLOADURL" -Ddatabus.labelPrefix="$LABELPREFIX" -Ddatabus.commentPrefix="$COMMENTPREFIX";


