#!/bin/bash


HELP="description:
marvin_extraction_run.sh and databus-release.sh take one argument, which is the extraction group
selects download.\$GROUP.properties and extraction.\$GROUP.properties from extractionConfig dir and uses \$GROUP as a path.

usage: 
./marvin_extraction_run.sh {test|generic|generic.en|mappings|wikidata|text|sparktestgeneric}
"

##############
# setup paths
##############

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONFIGDIR="$ROOT/extractionConfiguration"
LOGDIR="$ROOT/logs/$(date +%Y-%m-%d)"  && mkdir -p $LOGDIR
DATABUSDIR="$ROOT/databus-poms"
MARVINEXTRACTIONDIR="$ROOT/marvin-extraction"
DIEFDIR="$MARVINEXTRACTIONDIR/extraction-framework"
EXTRACTIONBASEDIR="$MARVINEXTRACTIONDIR/wikidumps" && mkdir -p $EXTRACTIONBASEDIR

##############
# functions
##############

# extract data
extractDumps() {
    cd $DIEFDIR/dump;
	>&2 ../run extraction $CONFIGDIR/extraction.$GROUP.properties;
}


# post-processing, see http://dev.dbpedia.org/Post-Processing
postProcessing() {

    cd $DIEFDIR/scripts;
    # resolve transitive links for all, affects the 'redirects' dataset
    # TODO ResolveTransitiveLinks can take a wikidata interlanguage link parameter, that helps to sort the redirects
    >&2 ../run ResolveTransitiveLinks $EXTRACTIONBASEDIR redirects redirects_transitive .ttl.bz2 @downloaded;

	# Datasets for MapObjectURIs
    if [ "$GROUP" = "mappings" ] || [ "$GROUP" = "test" ] 
    then
		DATASETS="mappingbased-objects-uncleaned"
    elif [ "$GROUP" = "wikidata" ]
    then
		DATASETS="mappingbased-objects-uncleaned,raw"
    elif [ "$GROUP" = "generic" ] || [ "$GROUP" = "generic.en" ] || [ "$GROUP" = "sparktestgeneric" ]
    then
		DATASETS="disambiguations,infobox-properties,page-links,persondata,topical-concepts"
	fi
	#run mapobjectURIs 
	>&2 ../run MapObjectUris $EXTRACTIONBASEDIR redirects_transitive .ttl.bz2 $DATASETS _redirected .ttl.bz2 @downloaded;

	# Datasets with Typeconsistencycheck
	if [ "$GROUP" = "mappings" ] || [ "$GROUP" = "test" ] || [ "$GROUP" = "wikidata" ] || [ "$GROUP" = "generic" ] || [ "$GROUP" = "generic.en" ] || [ "$GROUP" = "sparktestgeneric" ]
	then
		>&2 ../run TypeConsistencyCheck type.consistency.check.properties;
	fi
     
     # Handling of redirects, i.e. copy to log and rename old
	 mkdir -p $LOGDIR/unredirected/
	 for redirectedFile in $(find $EXTRACTIONBASEDIR -name "*_redirected.ttl.bz2") ; do 
        unredirectedFile=$(echo $redirectedFile | sed 's|_redirected\.ttl\.bz2$|\.ttl\.bz2|g');
        [ -f $unredirectedFile ] && cp -vn "$unredirectedFile" "$LOGDIR/unredirected/";
        # cp -vn $redirectedFile $LOGDIR/redirected;
        rename -f 's/_redirected//' $redirectedFile;
	 done
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
