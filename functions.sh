#!/bin/bash

# check git, curl, maven, java (1.8), lbzip2


prepareExtractionFramework(){
	if [ "$SKIPDIEFINSTALL" = "false" ]
    then
		# TODO make sure this contains marvin-config/marvin-extraction and replace with -rf
		rm -rI $DIEFDIR
		git clone "https://github.com/dbpedia/extraction-framework.git" $DIEFDIR
		cd $DIEFDIR
        # todo add config
        #cd $ROOT && cp $ROOT/config.d/universal.properties.template $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
		#sed -i -e 's,$BASEDIR,'$EXTRACTIONBASEDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
		#sed -i -e 's,$LOGDIR,'$LOGDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;

		mvn clean install
    else
		echo "skipping DIEF installation"
    fi
}


# downlaod and extract data
extractDumps() {
    cd $DIEFDIR/dump;

	# run for all 
    >&2 ../run extraction $ROOT/config.d/extraction.$GROUP.properties;

    # exceptions
    
    ## for generic, as English is big and has to be run separately
    if [ "$GROUP" = "generic" ]
    then
       >&2 ../run sparkextraction $ROOT/config.d/extraction.generic.en.properties;
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
    
    # todo check BASEDIR

    if [ "$GROUP" = "mappings" ]
    then
        >&2 ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 mappingbased-objects-uncleaned _redirected .ttl.bz2 @downloaded;
        >&2 ../run TypeConsistencyCheck type.consistency.check.properties;
    elif [ "$GROUP" = "wikidata" ]
    then
        >&2 ../run ResolveTransitiveLinks $BASEDIR redirects transitive-redirects .ttl.bz2 wikidata
        >&2 ../run MapObjectUris $BASEDIR transitive-redirects .ttl.bz2 mappingbased-objects-uncleaned,raw -redirected .ttl.bz2 wikidata
        >&2 ../run TypeConsistencyCheck type.consistency.check.properties;
    elif [ "$GROUP" = "generic" ] 
    then
        >&2 ../run ResolveTransitiveLinks $BASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $BASEDIR redirects_transitive .ttl.bz2 disambiguations,infobox-properties,page-links,persondata,topical-concepts _redirected .ttl.bz2 @downloaded;
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
    for f in $(find $LOGDIR -type f ); do lbzip2 $f; done;
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


