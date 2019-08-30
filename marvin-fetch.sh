#!/bin/bash


# ./marvin-fetch.sh wikidata 2019.08.01 dbpedia-wikidata.tib.eu 


GROUP=$1
VERSION=$2
SERVER=$3

# get artifacts
ARTIFACTS=`xmlstarlet sel -N my=http://maven.apache.org/POM/4.0.0 -t -v "/my:project/my:modules/my:module" $GROUP/pom.xml`

for a in $ARTIFACTS ; do 
echo $i 
#scp -rv marvin-fetch@$SERVER:/data/databus-maven-plugin/dbpedia/$GROUP/$a/$VERSION $GROUP/$a/
rsync -av -e ssh --ignore-existing marvin-fetch@$SERVER:/data/databus-maven-plugin/dbpedia/$GROUP/$a/$VERSION $GROUP/$a
done 
