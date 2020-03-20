#!/bin/bash


HELP="description:
marvin_extraction_run.sh and databus-release.sh take one argument, which is the extraction group
selects download.\$GROUP.properties and extraction.\$GROUP.properties from extractionConfig dir and uses \$GROUP as a path.

usage: 
./marvin_extraction_run.sh {test|generic|mappings|wikidata|text}
"

##############
# setup paths
##############

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONFIGDIR="$ROOT/extractionConfiguration"
DIEFDIR="$ROOT/marvin-extraction/extraction-framework"
LOGDIR="$ROOT/marvin-extraction/logs/$(date +%Y-%m-%d)"  && mkdir -p $LOGDIR
EXTRACTIONBASEDIR="$ROOT/marvin-extraction/wikidumps" && mkdir -p $EXTRACTIONBASEDIR
DATABUSDIR="$ROOT/databus-poms"

##############
# functions
##############

# extract data
extractDumps() {
    cd $DIEFDIR/dump;

    # exception for generic, 1. spark, 2. as English is big and has to be run separately
    if [ "$GROUP" = "generic" ]
    then
       >&2 ../run sparkextraction $CONFIGDIR/extraction.generic.properties;
       >&2 ../run sparkextraction $CONFIGDIR/extraction.generic.en.properties;
    elif ["$GROUP" = "text" ]
    then
      #>&2 ../run extraction $CONFIGDIR/extraction.$GROUP.en.properties;
      >&2 ../run extraction $CONFIGDIR/extraction.$GROUP.properties;
    else
	# run for all
	>&2 ../run extraction $CONFIGDIR/extraction.$GROUP.properties;
    fi

}


# post-processing
postProcessing() {

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
		# todo untested line
		for i in $(find $EXTRACTIONBASEDIR -name "*._redirects.ttl.bz2") ; do cp $i $LOGDIR ; rename -f 's/_redirected//' $i ; done
    elif [ "$GROUP" = "text" ]
    then
        echo "check whether text has post-processing"

    elif [ "$GROUP" = "test" ]
    then 
        >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;
        >&2 ../run MapObjectUris $EXTRACTIONBASEDIR redirects_transitive .ttl.bz2 mappingbased-objects-uncleaned _redirected .ttl.bz2 @downloaded;
        >&2 ../run TypeConsistencyCheckManual mappingbased-objects instance-types ro;
    fi
}

# compress log files
# log files from same day get overwritten, only latest is kept
archiveLogFiles() {
    for f in $(find $LOGDIR -type f ); do lbzip2 -f $f; done;
}



##########################
# Databus Mapping
##########################

# switch case for some language exceptions
mapLangToContVar() {
    lang=$(echo "$1" | sed 's|wiki||g')
    case "$lang" in
        "bat_smg") echo "_lang=batsmg";;
        "zh_min_nan") echo "_lang=nan";;
        "zh_yue") echo "_lang=yue";;
        "data") echo "";;
        "commons" ) echo "_commons";;
        *) echo "_lang=$lang";;
    esac
}


mapNamesToDatabus() {

    case "$1" in

	# generic
        "article-templates-nested") echo "article-templates_nested";;
        "citation-data") echo "citations_data";;
        "citation-links") echo "citations_links";;
        "commons-page-links") echo "commons-sameas-links";;
        "page-ids") echo "page_ids";;
        "page-length") echo "page_length";;
        "page-links") echo "wikilinks";;
        "article-categories") echo "categories_articles";;
        "category-labels") echo "categories_labels";;
        "skos-categories") echo "categories_skos";;
        "revision-ids") echo "revisions_ids";;
        "revision-uris") echo "revisions_uris";;

       # mappings
	"mappingbased-objects-disjoint-domain") echo "mappingbased-objects_disjointDomain";;
	"mappingbased-objects-disjoint-range")  echo "mappingbased-objects_disjointRange";;

	# wikidata
	"alias-nmw") echo "alias_nmw";;
	"description-nmw") echo "description_nmw";;
	"labels-nmw") echo "labels_nmw";;
	"mappingbased-properties-reified-qualifiers") echo "mappingbased-properties-reified_qualifiers";;
	"mappingbased-objects-uncleaned-redirected") echo "mappingbased-objects";;
	"revision-ids") echo "revisions_ids";;
	"revision-uris") echo "revisions_uris";;
	"wikidata-duplicate-iri-split") echo "debug_duplicateirisplit";;
	"wikidata-r2r-mapping-errors") echo "debug_r2rmappingerrors";;
	"wikidata-type-like-statements") echo "debug_typelikestatements";;
	"transitive-redirects") echo "redirects_transitive";;

	# both mappings and wikidata
	"instance-types") echo "instance-types_specific";;
	"instance-types-transitive") echo "instance-types_transitive";;

        *) echo "$1";;
    esac
}

# creates links in databus dir
mapAndCopy() {
	# each individual file
	path=$1

	# split filename
	# how to use ${string##/*}
	# https://www.tldp.org/LDP/abs/html/string-manipulation.html#Substring%20Removal#Substring Removal
	file="${path##*/}"

	version="${file#*-}"
	version="${version%%-*}"
	version="${version:0:4}.${version:4:2}.${version:6:2}"

	lang="${file%%-*}"

	extraction="${file#*-*-}"
	extraction="${extraction%%.*}"
	extraction=$(echo -n $extraction | sed 's|interlanguage-links-|interlanguage-links_lang=|') # generic exception

	extensions="${file#*.}"

	# map names and languages
	mapped="$(mapNamesToDatabus $extraction)"
	contVars="$(mapLangToContVar $lang)"
	if [[ "$mapped" == *"_"* ]]; then
		contVars="${contVars}_${mapped#*_}"
	fi
	artifact="${mapped%%_*}"
	targetFolder="$DATABUSDIR/dbpedia/$GROUP/$artifact/$version"
	targetFile="$artifact$contVars.$extensions"

	if [ -d "$DATABUSDIR/dbpedia/$GROUP/$artifact" ]; then
		mkdir -p $targetFolder
	else
		echo "[DEBUG]\"$artifact\" (artifact not found, might not be in group $GROUP) $path" >&2;
	fi

	# TODO proper handling of "_redirected"
	# TODO see above, redirected are moved to logdir and overwrite the unredirected
	# concerns only generic:
	# < enwiki/20191001/enwiki-20191001-disambiguations_redirected.ttl.bz2
	# < enwiki/20191001/enwiki-20191001-infobox-properties_redirected.ttl.bz2
	# < enwiki/20191001/enwiki-20191001-page-links_redirected.ttl.bz2
	# < enwiki/20191001/enwiki-20191001-persondata_redirected.ttl.bz2
	# < enwiki/20191001/enwiki-20191001-topical-concepts_redirected.ttl.bz2

	# copy
	# TODO comment  after testing
	cp -n "$path" "$targetFolder/$targetFile"
	# ln -s "$path" "$targetFolder/$targetFile"
	echo -e "< $path\n> $targetFolder/$targetFile\n----------------------"

}

diefCommitLink() {

	cd $DIEFDIR
	echo "https://github.com/dbpedia/extraction-framework/commit/$(git rev-parse @)"
}
