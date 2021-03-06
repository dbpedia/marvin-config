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
# Server DownloadURL
##################
DOMAIN=$GROUP

if [ "$GROUP" = "generic" ] || [ "$GROUP" = "mappings" ] 
then
    DOMAIN="mappings"
elif [ "$GROUP" = "text" ] 
then
     DOMAIN="generic"
fi


##################
# Setup and clone pom files
#################

#/data/extraction/wikidumps/enwiki/20191001

# git clone "https://github.com/dbpedia/databus-maven-plugin.git" $DATABUSDIR &>/dev/null
# cd $DATABUSDIR
# git pull


# creates links in databus dir
# iterate all .ttl.bz2 files
# uncomment for testing
latestDumpDate=$(find "$EXTRACTIONBASEDIR" -mindepth 2 -maxdepth 2 -type d -regextype grep -regex ".*[0-9]\{8\}$" | sort -n | tail -1 | xargs basename)
# uncomment next line for all dumps
# latestDumpDate=".*"
for path in $(find "$EXTRACTIONBASEDIR" -regex ".*/$latestDumpDate/.*\.ttl.bz2" | sort); do
   mapAndCopy $path
done


# deploy
cd $DATABUSDIR/dbpedia/$GROUP;
VERSION=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1)
echo $VERSION
mvn versions:set -DnewVersion=$VERSION;

# get git commit link
GITHUBLINK="$(diefCommitLink)"
PUBLISHER="https://vehnem.github.io/webid.ttl#this";
PACKAGEDIR="/var/www/dbpedia-$DOMAIN.tib.eu/databus-repo/marvin/\${project.groupId}/\${project.artifactId}";
DOWNLOADURL="http://dbpedia-$DOMAIN.tib.eu/databus-repo/marvin/\${project.groupId}/\${project.artifactId}/\${project.version}/";
LABELPREFIX="(pre-release) ";
COMMENTPREFIX="(MARVIN is the DBpedia bot for monthly raw releases (unparsed, unsorted) for debugging the DIEF software, commit: $GITHUBLINK . After its releases, data is cleaned and persisted under the DBpedia account. ) " ;

echo "VARS:
GITHUBLINK: $GITHUBLINK
PUBLISHER: $PUBLISHER
PACKAGEDIR: $PACKAGEDIR
DOWNLOADURL: $DOWNLOADURL
LABELPREFIX: $LABELPREFIX
COMMENTPREFIX:$COMMENTPREFIX
"

# TODO workaround for the read time out exception 
for i in `ls -d */` ; 
do 
	cd $i ;
	mvn clean deploy -Ddatabus.pkcs12serverId="databus.marvin" -Ddatabus.publisher="$PUBLISHER" -Ddatabus.packageDirectory="$PACKAGEDIR" -Ddatabus.downloadUrlPath="$DOWNLOADURL" -Ddatabus.labelPrefix="$LABELPREFIX" -Ddatabus.commentPrefix="$COMMENTPREFIX";
	cd ..
done

