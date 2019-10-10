#!/bin/bash

set -e

# [CONFIG]

#extracted dumps (basedir)
BASEDIR="/data/extraction/wikidumps/"

#databus-maven-plugin project, containing release pom
DATABUSMVNPOMDIR="/data/extraction/databus-maven-plugin/dbpedia/generic"

#explicit databus version or empty for all
DUMPDATE=

#if true show dumy output
TRYRUN=false

# [DATASET-MAPPING]

mapLang() {

    lang=$(echo "$1" | sed 's|wiki||g')

    case "$lang" in

        "bat_smg") echo "_lang=batsmg";;
        "zh_min_nan") echo "_lang=nan";;
        "zh_yue") echo "_lang=yue";;

        "wikidata") echo "";;

        *) echo "_lang=$lang";;
    esac
}

mapExtraction() {

    case "$1" in
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

        *) echo "$1";;
    esac
}

# [FUNCTIONS]

collectExtractionFun() {

    #how to use ${string##/*}
    #https://www.tldp.org/LDP/abs/html/string-manipulation.html#Substring%20Removal#Substring Removal

    for path in $(find "$BASEDIR" -name "*.ttl.bz2"); do

        file="${path##*/}"

        version="${file#*-}"
        version="${version%%-*}"
        version="${version:0:4}.${version:4:2}.${version:6:2}"

        if [ "$DUMPDATE" = "$version" ] || [ -z "$DUMPDATE" ]  ; then

            lang="${file%%-*}"

            extraction="${file#*-*-}"
            extraction="${extraction%%.*}"

            extension="${file#*.}"

            mapped="$(mapExtraction $extraction)"

            artifact="${mapped%%_*}"

            contVars="$(mapLang $lang)"
            if [[ "$mapped" == *"_"* ]]; then
                contVars="${contVars}_${mapped#*_}"
            fi

            targetArVe="$artifact/$version"
            targetFile="$artifact$contVars.$extension"

            if [ -d "$DATABUSMVNPOMDIR/$artifact" ]; then

                if [ ! -d "$DATABUSMVNPOMDIR/$targetArVe" ]; then

                    mkdir -p "$DATABUSMVNPOMDIR/$targetArVe"
                fi

                if $TRYRUN; then
                    echo "$path -> $DATABUSMVNPOMDIR/$targetArVe/$targetFile"
                else
                    cp -vn "$path" "$DATABUSMVNPOMDIR/$targetArVe/$targetFile"
                fi
            else

                >&2 echo "unmapped/notexist artifact: $artifact | $mapped | $extraction"
            fi
        fi
    done
}

renameRedirected() {
    cd $DATABUSMVNPOMDIR;
#    for f in $(find . -name "*_redirected*" ); do rename -n 's/_redirected\.ttl\.bz2$/\.ttl\.bz2$/' $f; done
    for f in $(find . -name "*_redirected*" ); do rename -n 's/_redirected//' $f; done
}

# [Main]

main() {
    collectExtractionFun;
}

main;
