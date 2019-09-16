#!/bin/bash

set -e

SCRIPTROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";

# [CONFIG]

#extraction-framework
EXTRACTIONFRAMEWORKDIR="/home/extractor/extraction-framework";

#extracted dumps (basedir)
BASEDIR="/data/extraction/wikidumps";

#databus-maven-plugin project, containing release pom
#https://github.com/dbpedia/databus-maven-plugin/blob/master/dbpedia/generic/pom.xml
DATABUSMAVENPOMDIR="/data/extraction/databus-maven-plugin/dbpedia/generic";

#override release pom.xml properties
RELEASEPUBLISHER="https://vehnem.github.io/webid.ttl#this";
RELEASEPACKAGEDIR="/data/extraction/release";
RELEASEDOWNLOADURL="http://dbpedia-generic.tib.eu/release";
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

downloadDumps() {
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    ../run download $SCRIPTROOT/download.generic.properties;
}

buildExtractionFramework() {
    cd $EXTRACTIONFRAMEWORKDIR;
    mvn clean install;
}

runExtraction() {
    cd $EXTRACTIONFRAMEWORKDIR/dump;
    ../run sparkextraction $SCRIPTROOT/sparkextraction.generic.properties;
    ../run sparkextraction $SCRIPTROOT/sparkextraction.generic.en.properties;
}

resolveTransitiveLinks() {
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
}

mapObjectUris() {
    cd $EXTRACTIONFRAMEWORKDIR/scripts;
    ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 disambiguations,infobox-properties,page-links,persondata,topical-concepts _redirected .ttl.bz2 @downloaded;
}

postProcessing() {
    echo "$(date) | extraction-framework| resole transitive links" >&2;
    execWithLogging resolveTransitiveLinks;
    echo "$(date) | extraction-framework| map object uris" >&2;
    execWithLogging mapObjectUris;
}

prepareRelease() {
    #own config
    cd $SCRIPTROOT;
    bash collectExtraction.sh;
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

    echo "--------------------" >&2;
    echo " Generic Extraction " >&2;
    echo "--------------------" >&2;

    #download
    echo "$(date) | extraction-framework | start download ontology" >&2;
    execWithLogging downloadOntology;
    echo "$(date) | extraction-framework | start download mappings" >&2;
    execWithLogging downloadMappings;
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
}

if [ ! -f "$SCRIPTROOT/generic-release.pid" ]; then
        (execWithLogging main; rm "$SCRIPTROOT/generic-release.pid") & echo $! > "$SCRIPTROOT/generic-release.pid"
fi
