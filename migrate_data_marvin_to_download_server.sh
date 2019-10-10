#!/bin/bash
# ./marvin-fetch.sh wikidata 2019.08.01 

GROUP=$1
VERSION=$2
SERVER=dbpedia-$1.tib.eu

# get artifacts
ARTIFACTS=`xmlstarlet sel -N my=http://maven.apache.org/POM/4.0.0 -t -v "/my:project/my:modules/my:module" $GROUP/pom.xml`

for ARTIFACT in $ARTIFACTS ; do 
	echo $ARTIFACT 
	#scp -rv marvin-fetch@$SERVER:/data/databus-maven-plugin/dbpedia/$GROUP/$a/$VERSION $GROUP/$a/
	rsync -av -e ssh --ignore-existing marvin-fetch@$SERVER:/data/derive/databus-maven-plugin/dbpedia/$GROUP/$ARTIFACT/$VERSION $GROUP/$ARTIFACT
done 
