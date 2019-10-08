#!/bin/bash

# setup
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATADIR=$SCRIPTDIR
LOGDIR=$DATADIR/logs
EXTRACTIONBASEDIR=$DATADIR/wikidumps
EXTRACTIONFRAMEWORKDIR=$DATADIR/extraction-framework
DATAPUSMAVENPLUGINPOMDIR=$DATADIR/databus-maven-plugin
RELEASEDIR=$DATADIR/release

DATAPUSMAVENPLUGINPOMGIT=https://github.com/dbpedia/databus-maven-plugin.git    
EXTRACTIONFRAMEWORKGIT=https://github.com/dbpedia/extraction-framework.git

# arguments
HELP="usage: --group={generic|mappings|wikidata} [--skip-release|--skip-mvn-install]"
GROUP=
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

if [ "$GROUP" != "generic" ] && [ "$GROUP" != "mappings" ] && [ "$GROUP" != "test" ]&& [ "$GROUP" != "wikidata" ] || [ -z "$GROUP" ]; then
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
    cd $DATADIR;
    cp $SCRIPTDIR/config.d/universal.properties.template $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
    sed -i -e 's,$BASEDIR,'$EXTRACTIONBASEDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
    sed -i -e 's,$LOGDIR,'$LOGDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;

    if [ "$SKIPMVNINSTALL" = "false" ]; then
        cd $EXTRACTIONFRAMEWORKDIR && mvn install;
    fi

    if [ "$GROUP" = "mappings" ]; then
        echo 1
    elif [ "$GROUP" = "wikidata" ]; then
        echo 2 
    elif [ "$GROUP" =  "generic" ]; then
        echo 3
    elif [ "$GROUP" = "test" ]; then
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run download $SCRIPTDIR/config.d/download.test.properties
        cd $EXTRACTIONFRAMEWORKDIR/dump && ../run extraction $SCRIPTDIR/config.d/extraction.test.properties
    fi
}

# clean up: compress log files
clean() {
    for f in $(find $LOGDIR -type f ); do lbzip2 $f; done;
}

main() {

    # PRE
    createDirectories;
    gitCheckout;
    downloadMetadata &> $LOGDIR/downloadMetadata.log;

    # EXTRACT
    extractDumps &> $LOGDIR/extracion.log;

    # POST

    # RELEASE 
    if [ "$SKIPRELEASE" = "false" ]; then
        echo true
    fi

    # CLEAN
    
}
main