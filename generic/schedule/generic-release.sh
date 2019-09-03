#!/bin/bash

set -e

SCRIPTROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

EXTRACTIONFRAMEWORK="/home/extractor/extraction-framework"
DATABUSMAVENPLUGIN="/data/extraction/databus-maven-plugin/dbpedia/generic"

BASEDIR="/data/extraction/wikidumps"

LOGS="/data/extraction/logs/$(date +%Y-%m-%d)"
mkdir -p $LOGS

execWithLogging() {
    # arg(0) funcName
    $1 > "$LOGS/$1.out" 2> "$LOGS/$1.err"
}

downloadOntology() {
	cd $EXTRACTIONFRAMEWORK/core;
	../run download-ontology;
}

downloadMappings() {
	cd $EXTRACTIONFRAMEWORK/core;
	../run download-mappings;
}

downloadDumps() {
	cd $EXTRACTIONFRAMEWORK/dump;
	../run download download.spark.properties;
}

buildExtractionFramework() {
	cd $EXTRACTIONFRAMEWORK;
	mvn clean install;
}

runExtraction() {
	cd $EXTRACTIONFRAMEWORK/dump;
	../run sparkextraction extraction.spark.properties;
}

resolveTransitiveLinks() {
    cd $EXTRACTIONFRAMEWORK/scripts;
    ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded
}

mapObjectUris() {
    cd $EXTRACTIONFRAMEWORK/scripts;
    ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 disambiguations,infobox-properties,page-links,persondata,topical-concepts _redirected .ttl.bz2 @downloaded
}

postProcessing() {
    echo "$(date) | extraction-framework| resole transitive links" >&2;
    execWithLogging resolveTransitiveLinks;
    echo "$(date) | extraction-framework| map object uris" >&2
    execWithLogging mapObjectUris;
}

prepareRelease() {
	# own config
	cd $SCRIPTROOT;
	./collectExtraction.sh;
}

deployRelease() {
	cd $DATABUSMAVENPLUGIN;
	mvn deploy;
}

compressLogs() {

    for f in $(find $LOGS -type f ); do lbzip2 $f; done
}

main() {

	echo "--------------------" >&2;
	echo " Generic Extraction " >&2;
	echo "--------------------" >&2;

    # DOWNLOAD
	echo "$(date) | extraction-framework | start download ontology" >&2;
	execWithLogging downloadOntology;
	echo "$(date) | extraction-framework | start download mappings" >&2;
	execWithLogging downloadMappings;
	echo "$(date) | extraction-framework | start download dumps" >&2;
	execWithLogging downloadDumps;

    # EXTRACTION
    echo "$(date) | extraction-framework | mvn clean install" >&2;
	execWithLogging buildExtractionFramework;
    echo "$(date) | extraction-framework | start extraction" >&2;
	execWithLogging runExtraction;
    echo "$(date) | extraction-framework | post processing" >&2;
	postProcessing;

	# DATABUS RELEASE
    echo "$(date) | databus-maven-plugin | collect extracted datasets" >&2;
	execWithLogging prepareRelease;
    echo "$(date) | databus-maven-plugin | mvn deploy" >&2;
	execWithLogging deployRelease;

    # LOGGING CLEANUP
    echo "$(date) | main | compress log files" >&2;
    compressLogs;
}

