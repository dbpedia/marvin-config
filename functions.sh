#!/bin/bash


##############
# setup paths
##############

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONFIGDIR="$ROOT/extractionConfiguration"
DIEFDIR="$ROOT/marvin-extraction/extraction-framework"
LOGDIR="$ROOT/marvin-extraction/logs/$(date +%Y-%m-%d)"  && mkdir -p $LOGDIR
EXTRACTIONBASEDIR="$ROOT/marvin-extraction/wikidumps" && mkdir -p $EXTRACTIONBASEDIR

# TODO
RELEASEDIR="$ROOT/marvin-extraction/release"
DATAPUSMAVENPLUGINPOMDIR="$ROOT/databus-maven-plugin"
DATAPUSMAVENPLUGINPOMGIT="https://github.com/dbpedia/databus-maven-plugin.git"    

# mkdir -p $RELEASEDIR

##############
# functions
##############

# downlaod and extract data
extractDumps() {
    cd $DIEFDIR/dump;
        
    # exception for generic, 1. spark, 2. as English is big and has to be run separately
    if [ "$GROUP" = "generic" ]
    then
       >&2 ../run sparkextraction $CONFIGDIR/extraction.generic.properties;
       >&2 ../run sparkextraction $CONFIGDIR/extraction.generic.en.properties;
    else
		# run for all 
	    >&2 ../run extraction $CONFIGDIR/extraction.$GROUP.properties;
    
    fi    
   
}


# post-processing
postProcessing() {
	
	# TODO move databus scripts in extra function
    #       cd $CONFIGDIR;
    #       source prepareMappingsArtifacts.sh; BASEDIR=$EXTRACTIONBASEDIR; DATABUSMVNPOMDIR=$DATAPUSMAVENPLUGINPOMDIR;
    #      prepareM;


    cd $DIEFDIR/scripts;
    echo "post-processing of $GROUP"
    
    if [ "$GROUP" = "mappings" ]
    then
        >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $EXTRACTIONBASEDIR redirects_transitive .ttl.bz2 mappingbased-objects-uncleaned _redirected .ttl.bz2 @downloaded;
        >&2 ../run TypeConsistencyCheck type.consistency.check.properties;
    elif [ "$GROUP" = "wikidata" ]
    then
        >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects transitive-redirects .ttl.bz2 wikidata
        >&2 ../run MapObjectUris $EXTRACTIONBASEDIR transitive-redirects .ttl.bz2 mappingbased-objects-uncleaned,raw -redirected .ttl.bz2 wikidata
        >&2 ../run TypeConsistencyCheck type.consistency.check.properties;
    elif [ "$GROUP" = "generic" ] 
    then
        >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $EXTRACTIONBASEDIR redirects_transitive .ttl.bz2 disambiguations,infobox-properties,page-links,persondata,topical-concepts _redirected .ttl.bz2 @downloaded;
    elif [ "$GROUP" = "abstract" ]
    then
        echo "TODO"

    elif [ "$GROUP" = "test" ]
    then 
        >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $EXTRACTIONBASEDIR redirects_transitive .ttl.bz2 mappingbased-objects-uncleaned _redirected .ttl.bz2 @downloaded;
        >&2 ../run TypeConsistencyCheckManual mappingbased-objects instance-types ro;
    fi
}

# compress log files
archiveLogFiles() {
	# todo copy to some archive
    for f in $(find $LOGDIR -type f ); do lbzip2 -f $f; done;
}



########################################################################
#### TODO CLEAN UP BELOW
########################################################################


# clone repositories
gitCheckout() {
    if [ -d $EXTRACTIONFRAMEWORKDIR/.git ]
    then
        cd $EXTRACTIONFRAMEWORKDIR;
        echo -n "extraction-framework "
        git pull;
    else 
        git clone $EXTRACTIONFRAMEWORKGIT
    fi
    if [ -d $DATAPUSMAVENPLUGINPOMDIR/.git ]
    then
        cd $DATAPUSMAVENPLUGINPOMDIR;
        echo -n "databus-maven-plugin "
        git pull;
    else 
        git clone $DATAPUSMAVENPLUGINPOMGIT
    fi
}

# download ontology, mappings, wikidataR2R
downloadMetadata() {
    cd $DIEFDIR/core;
    ../run download-ontology;
    ../run download-mappings;
    
	# TODO check prepare above, this line seems unneccessary now	
    # cd $DIEFDIR/core/src/main/resources;
    # curl https://raw.githubusercontent.com/dbpedia/extraction-framework/master/core/src/main/resources/wikidatar2r.json > wikidatar2r.json;
}


# release
databusRelease() {

    if [ "$DATABUSDEPLOY" = "true" ]
    then
        cd $DATAPUSMAVENPLUGINPOMDIR;
        mvn versions:set -DnewVersion=$(ls * | grep '^[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}$' | sort -u  | tail -1);

        RELEASEPUBLISHER="https://vehnem.github.io/webid.ttl#this";
        RELEASEPACKAGEDIR="/data/extraction/release/\${project.groupId}/\${project.artifactId}";
        RELEASEDOWNLOADURL="http://dbpedia-generic.tib.eu/release/\${project.groupId}/\${project.artifactId}/\${project.version}/";
        RELEASELABELPREFIX="(pre-release)";
        RELEASECOMMENTPREFIX="(MARVIN is the DBpedia bot, that runs the DBpedia Information Extraction Framework (DIEF) and releases the data as is, i.e. unparsed, unsorted, not redirected for debugging the software. After its releases, data is cleaned and persisted under the dbpedia account.)";

        >&2 mvn clean deploy -Ddatabus.publisher="$RELEASEPUBLISHER" -Ddatabus.packageDirectory="$RELEASEPACKAGEDIR" -Ddatabus.downloadUrlPath="$RELEASEDOWNLOADURL" -Ddatabus.labelPrefix="$RELEASELABELPREFIX" -Ddatabus.commentPrefix="$RELEASECOMMENTPREFIX";
    fi
}


