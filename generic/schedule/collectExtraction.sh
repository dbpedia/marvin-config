#!/bin/bash

set -e

# directory of extracted dumps. (basedir)
BASEDIR="/data/extraction/wikidumps/"

# databus-maven-plugin directory
DATABUSMVNDIR="/data/extraction/databus-maven-plugin/dbpedia/generic"

# databus version. empty for all
DUMPDATE=

# if true, just show what will happen
TRYRUN=false

#__Maps__

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

#__Functions__

printStart() {

    >&2 echo "-----------------"
    >&2 echo " Generic Release "
    >&2 echo "-----------------"
}

copyToMavenPlugin() {

    # https://www.tldp.org/LDP/abs/html/string-manipulation.html#Substring%20Removal#Substring Removal
    # ${string##/*}

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

            if [ -d "$DATABUSMVNDIR/$artifact" ]; then

                if [ ! -d "$DATABUSMVNDIR/$targetArVe" ]; then

                    mkdir -p "$DATABUSMVNDIR/$targetArVe"
                fi

                if $TRYRUN; then
                    echo "$path -> $DATABUSMVNDIR/$targetArVe/$targetFile"
                else
                    cp -vn "$path" "$DATABUSMVNDIR/$targetArVe/$targetFile"
                fi
            else

                >&2 echo "unmapped/notexist artifact: $artifact"
            fi
        fi
    done
}


#__Main__

main() {

    printStart
    copyToMavenPlugin

    #TODO add release
}
main
