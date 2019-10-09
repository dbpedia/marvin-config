#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# setup
LOGDIR="$ROOT/logs/$(date +%Y-%m-%d)"
EXTRACTIONBASEDIR="$ROOT/wikidumps"
EXTRACTIONFRAMEWORKDIR="$ROOT/extraction-framework"
DATAPUSMAVENPLUGINPOMDIR="$ROOT/databus-maven-plugin"
RELEASEDIR="$ROOT/release"

DATAPUSMAVENPLUGINPOMGIT="https://github.com/dbpedia/databus-maven-plugin.git"    
EXTRACTIONFRAMEWORKGIT="https://github.com/dbpedia/extraction-framework.git"

# arguments
HELP="usage: --group={generic|mappings|wikidata} [--skip-release|--skip-mvn-install]"
GROUP=""
SKIPRELEASE=false
SKIPMVNINSTALL=false

for i in "$@"
do
case $i in
    -g=*|--group=*)
    GROUP="${i#*=}"
    shift
    ;;
    --skip-release)
    SKIPRELEASE=true
    shift
    ;;
    --skip-mvn-install)
    SKIPMVNINSTALL=true
    shift
    ;;
    -h|--help)
    echo -e $HELP
    exit 1
    shift
    ;;
    *)
    echo "unknown option: $i"
    echo $HELP
    exit 1
    ;;
esac
done

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ] && [ "$GROUP" != "wikidata" ] || [ -z "$GROUP" ]; then
    echo $HELP
    exit 1
fi

# check git, curl, maven, java (1.8), lbzip2

# create directories
createDirectories() {
    mkdir -p $EXTRACTIONBASEDIR
    mkdir -p $LOGDIR
    mkdir -p $RELEASEDIR
}

# clone repositories
gitCheckout() {
    if [ -d $EXTRACTIONFRAMEWORKDIR/.git ]; then
        cd $EXTRACTIONFRAMEWORKDIR;
        echo -n "extraction-framework "
        git pull;
    else 
        git clone $EXTRACTIONFRAMEWORKGIT
    fi
    if [ -d $DATAPUSMAVENPLUGINPOMDIR/.git ]; then
        cd $DATAPUSMAVENPLUGINPOMDIR;
        echo -n "databus-maven-plugin "
        git pull;
    else 
        git clone $DATAPUSMAVENPLUGINPOMGIT
    fi
}

# download ontology, mappings, wikidataR2R
downloadMetadata() {
    cd $EXTRACTIONFRAMEWORKDIR/core && ../run download-ontology;
    cd $EXTRACTIONFRAMEWORKDIR/core && ../run download-mappings;
    cd $EXTRACTIONFRAMEWORKDIR/core/src/main/resources && curl https://raw.githubusercontent.com/dbpedia/extraction-framework/master/core/src/main/resources/wikidatar2r.json > wikidatar2r.json
}

# downlaod and extract data
extractDumps() {
    cd $ROOT && cp $ROOT/config.d/universal.properties.template $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
    sed -i -e 's,$BASEDIR,'$EXTRACTIONBASEDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
    sed -i -e 's,$LOGDIR,'$LOGDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;

    if [ "$SKIPMVNINSTALL" = "false" ]; then
        echo "extraction-framework: mvn install"
        cd $EXTRACTIONFRAMEWORKDIR && mvn install;
    fi

    if [ "$GROUP" = "mappings" ]; then
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run download $ROOT/config.d/download.mappings.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run extraction $ROOT/config.d/extraction.mappings.properties
    elif [ "$GROUP" = "wikidata" ]; then
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run download $ROOT/config.d/download.wikidata.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run extraction $ROOT/config.d/extraction.wikidata.properties
    elif [ "$GROUP" =  "generic" ]; then
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run download $ROOT/config.d/download.generic.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run sparkextraction $ROOT/config.d/sparkextraction.generic.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run sparkextraction $ROOT/config.d/sparkextraction.generic.en.properties
    elif [ "$GROUP" = "test" ]; then
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run download $ROOT/config.d/download.test.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run extraction $ROOT/config.d/extraction.test.properties
    elif [ "$GROUP" = "abstract" ]; then
        echo "TODO abstract extraction and download"
    fi
}

# post-processing
postProcessing() {

    if [ "$GROUP" = "mappings"] || [ "$GROUP" = "test" ]; then
        echo "mappings postProcessing"
        cd $EXTRACTIONFRAMEWORKDIR/scripts;
        ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 mappingbased-objects-uncleaned _redirected .ttl.bz2 @downloaded;
        ../run TypeConsistencyCheck type.consistency.check.properties;
        # TODO prepareRelease
    elif [ "$GROUP" = "wikidata" ]; then
        echo "wikidata postProcessing"
        cd $EXTRACTIONFRAMEWORKDIR/scripts;
        ../run ResolveTransitiveLinks $BASEDIR redirects transitive-redirects .ttl.bz2 wikidata
        ../run MapObjectUris $BASEDIR transitive-redirects .ttl.bz2 mappingbased-objects-uncleaned,raw -redirected .ttl.bz2 wikidata
        ../run TypeConsistencyCheck type.consistency.check.properties;
        # TODO prepareRelease
    elif [ "$GROUP" = "generic" ]; then
        echo "generic postProcessing"
        cd $EXTRACTIONFRAMEWORKDIR/scripts;
        ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 disambiguations,infobox-properties,page-links,persondata,topical-concepts _redirected .ttl.bz2 @downloaded;
        # TODO prepareRelease
    elif [ "$GROUP" = "abstract" ]; then
        echo "abstract postProcessing"
    fi
}

# release
release() {
    cd $DATAPUSMAVENPLUGINPOMDIR;
    mvn versions:set -DnewVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1);

    RELEASEPUBLISHER="https://vehnem.github.io/webid.ttl#this";
    RELEASEPACKAGEDIR="/data/extraction/release/\${project.groupId}/\${project.artifactId}";
    RELEASEDOWNLOADURL="http://dbpedia-generic.tib.eu/release/\${project.groupId}/\${project.artifactId}/\${project.version}/";
    RELEASELABELPREFIX="(pre-release)";
    RELEASECOMMENTPREFIX="(MARVIN is the DBpedia bot, that runs the DBpedia Information Extraction Framework (DIEF) and releases the data as is, i.e. unparsed, unsorted, not redirected for debugging the software. After its releases, data is cleaned and persisted under the dbpedia account.)";

    mvn clean deploy -Ddatabus.publisher="$RELEASEPUBLISHER" -Ddatabus.packageDirectory="$RELEASEPACKAGEDIR" -Ddatabus.downloadUrlPath="$RELEASEDOWNLOADURL" -Ddatabus.labelPrefix="$RELEASELABELPREFIX" -Ddatabus.commentPrefix="$RELEASECOMMENTPREFIX";
}

# clean up: compress log files
clean() {
    for f in $(find $LOGDIR -type f ); do lbzip2 $f; done;
}

main() {

    # PRE-PROCESSING
    createDirectories;
    gitCheckout;
    downloadMetadata &> $LOGDIR/downloadMetadata.log;

    # EXTRACT
    extractDumps &> $LOGDIR/extracion.log;

    # POST-PROCESSING
    # postProcessing &> $LOGDIR/postProcessing.log;

    # RELEASE 
    # if [ "$SKIPRELEASE" = "false" ]; then
    #     echo true
    # fi

    # CLEAN
    # clean;
    
}
main