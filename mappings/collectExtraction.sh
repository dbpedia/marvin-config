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

        "commons" ) echo "_commons";;

        *) echo "_lang=$lang";;
    esac
}

mapExtraction() {

    case "$1" in

        "instance-types-transitive") echo "instance-types_transitive";;
		"mappingbased-objects-disjoint-domain") echo "mappingbased-objects_disjointDomain";;
		"mappingbased-objects-disjoint-range")  echo "mappingbased-objects_disjointRange";;

        *) echo "$1";;
    esac
}

# [FUNCTIONS]

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


# [MAIN]

main() {

    printStart
    copyToMavenPlugin

    #TODO add release
}
main
