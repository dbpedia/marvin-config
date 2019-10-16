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
DATABUSDIR="$ROOT/marvin-extraction/databus-maven-plugin"

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





