#!/bin/bash

set -e

SCRIPTROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# [CONFIG]

#extraction-framework
EXTRACTIONFRAMEWORKDIR="/home/extractor/extraction-framework";

#extracted dumps (basedir)
BASEDIR="/data/extraction/wikidumps";

#databus-maven-plugin project, containing release pom
#https://github.com/dbpedia/databus-maven-plugin/blob/master/dbpedia/wikidata/pom.xml
DATABUSMAVENPOMDIR="/data/extraction/databus-maven-plugin/dbpedia/wikidata";

#override release pom.xml properties
RELEASEPUBLISHER="https://vehnem.github.io/webid.ttl#this";
RELEASEPACKAGEDIR="/data/extraction/release";
RELEASEDOWNLOADURL="http://dbpedia-wikidata.tib.eu/release";
RELEASELABELPREFIX="(pre-release)"
RELEASECOMMENTPREFIX="(MARVIN is the DBpedia bot, that runs the DBpedia Information Extraction Framework (DIEF) and releases the data as is, i.e. unparsed, unsorted, not redirected for debugging the software. After its releases, data is cleaned and persisted under the dbpedia account.)"

#logging directory
LOGS="/data/extraction/logs/$(date +%Y-%m-%d)";
mkdir -p $LOGS;

# [FUNCTIONS]

execWithLogging() {
    #arg(0) = $1 := "function name"
    $1 > "$LOGS/$1.out" 2> "$LOGS/$1.err";
}

downloadOntology() {
    cd $EXTRACTIONFRAMEWORKDIR/core;
    ../run download-ontology;
}

downloadMappings() {
    cd $EXTRACTIONFRAMEWORKDIR/core;
    ../run download-mappings;
}

downloadR2R() {
    cd $EXTRACTIONFRAMEWORKDIR/core/src/main/resources && curl https://raw.githubusercontent.com/dbpedia/extraction-framework/master/core/src/main/resources/wikidatar2r.json > wikidatar2r.json
}

downloadDumps() {
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    ../run download $SCRIPTROOT/download.wikidata.properties;
}

buildExtractionFramework() {
    cd $EXTRACTIONFRAMEWORKDIR;
    mvn clean install;
}

runExtraction(){
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    ../run extraction extraction.wikidata.properties;
}

resolveTransitiveLinks() {
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run ResolveTransitiveLinks $BASEDIR redirects transitive-redirects .ttl.bz2 wikidata
}

mapObjectUris() {
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run MapObjectUris $BASEDIR transitive-redirects .ttl.bz2 mappingbased-objects-uncleaned,raw -redirected .ttl.bz2 wikidata
}

typeConsistencyCheck(){
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run TypeConsistencyCheck type.consistency.check.properties;
}

postProcessing() {
    echo "$(date) | extraction-framework| resole transitive links" >&2;
    execWithLogging resolveTransitiveLinks;
    echo "$(date) | extraction-framework| map object uris" >&2;
    execWithLogging mapObjectUris;
    echo "$(date) | extraction-framework| type consistency check" >&2;
    execWithLogging typeConsistencyCheck;
}

prepareRelease() {
    #own config
    #    cd $SCRIPTROOT;
    #    collectExtraction.sh;
    cd $SCRIPTROOT/schedule;
    bash prep.sh
}

setNewVersion() {
    cd $DATABUSMAVENPOMDIR;
    mvn versions:set -DnewVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1);
}

deployRelease() {
    cd $DATABUSMAVENPOMDIR;
    mvn deploy \
	-Ddatabus.publisher="$RELEASEPUBLISHER" \
	-Ddatabus.packageDirectory="$RELEASEPACKAGEDIR/\${project.groupId}/\${project.artifactId}" \
	-Ddatabus.downloadUrlPath="$RELEASEDOWNLOADURL/\${project.groupId}/\${project.artifactId}/\${project.version}" \
	-Ddatabus.labelPrefix="$RELEASELABELPREFIX" \
	-Ddatabus.commentPrefix="$RELEASECOMMENTPREFIX";
}

compressLogs() {
    for f in $(find $LOGS -type f ); do lbzip2 $f; done;
}

# [MAIN]
main() {

    #download
    echo "$(date) | extraction-framework | start download ontology" >&2;
    execWithLogging downloadOntology;
    echo "$(date) | extraction-framework | start download mappings" >&2;
    execWithLogging downloadMappings;
    echo "$(date) | extraction-framework | start download r2r mappings" >&2;
    execWithLogging downloadR2R;
    echo "$(date) | extraction-framework | start download dumps" >&2;
    execWithLogging downloadDumps;

    #extraction
    echo "$(date) | extraction-framework | mvn clean install" >&2;
    execWithLogging buildExtractionFramework;
    echo "$(date) | extraction-framework | start extraction" >&2;
    execWithLogging runExtraction;
    echo "$(date) | extraction-framework | post processing" >&2;
    postProcessing;

    #release
    echo "$(date) | databus-maven-plugin | collect extracted datasets" >&2;
    execWithLogging prepareRelease;
    echo "$(date) | databus-maven-plugin | mvn versions:set" >&2;
    execWithLogging setNewVersion;
    echo "$(date) | databus-maven-plugin | mvn deploy" >&2;
    execWithLogging deployRelease;

    #cleanup
    echo "$(date) | main | compress log files" >&2;
    compressLogs;

    #(DEPRECATED FUNCTIONS) below not configured yet

    ##Result of subclassof-script is used in next extraction.
    #subclassof-script;
    #databus-preparation;
    #Sync extraction with www
    #sync-with-www
    #remove-date-from-files

    #This was the previous extraction process. Now we don't need to run rawextractor separately
    # raw-extractor;
    # subclassof-script;
    # all-other-extractors;
    # post-processing;
}

if [ ! -f "$SCRIPTROOT/wikidata-release.pid" ]; then
        (execWithLogging main; rm "$SCRIPTROOT/wikidata-release.pid") & echo $! > "$SCRIPTROOT/wikidata-release.pid"
fi

# [DEPRECATED]

DATA_DIR=/data/extraction/wikidumps/
WWW_DIR=/var/www/html/wikidata

function sync-with-www(){
    rsync -avz $DATA_DIR/wikidatawiki/ $WWW_DIR/;

    #We don't need index.html
    find $WWW_DIR/ | grep index.html | xargs rm -rf;
}

function databus-preparation(){
    cd $DATA_DIR;
    bash ~/databusPrep.sh $WWW_DIR/ src/main/databus;
}

function delete-old-extractions(){
    #Delete extractions older than 1 month, i.e. keep 1-2 results in www.
    find $WWW_DIR/ -type d -ctime +20 | xargs rm -rf;

    #Remove everything in Dump dir, do we need to keep them?
    rm -rf $DATA_DIR/wikidatawiki/*;
}

function remove-date-from-files(){
    #Go to the last changed directory
    cd "$(\ls -1dt $WWW_DIR/*/ | head -n 1)";

    #Remove date (numbers) from files
    for i in *; do  mv "$i" "`echo $i| sed 's/[0-9]..//g'`"; done;
}

function raw-extractor(){
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    #Run only .WikidataRawExtractor
    ../run extraction extraction.wikidataraw.properties;
}

function subclassof-script(){
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run WikidataSubClassOf process.wikidata.subclassof.properties;
}

function all-other-extractors(){
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    # Run all other extractors
    ../run extraction extraction.wikidataexceptraw.properties
}

