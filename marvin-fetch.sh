#!/bin/bash

GROUP=$1
VERSION=$2

# get artifacts
ARTIFACTS=` xmlstarlet sel -N my=http://maven.apache.org/POM/4.0.0 -t -v "/my:project/my:modules/my:module" $GROUP/pom.xml`

#ARTIFACTS="geo-coordinates-mappingbased instance-types specific-mappingbased-properties mappingbased-literals mappingbased-objects-uncleaned"
#VERSION="2019.08.01"
for i in $ARTIFACTS ; do 
echo $i 
#scp -rv marvin-fetch@dbpedia-mappings.tib.eu:/data/databus-maven-plugin/dbpedia/mappings/$i/$VERSION $i/
done 
