#!/bin/bash

set -e

# [CONFIG]

#extracted dumps (basedir)
BASEDIR="/data/extraction/wikidumps/"

#databus-maven-plugin project, containing release pom
DATABUSMVNPOMDIR="/data/extraction/databus-maven-plugin/dbpedia/wikidata"

#explicit databus version or empty for all
DUMPDATE=

#if true show dumy output
TRYRUN=false

# [TODO]

echo "----------------------------"
echo "Prepare Wikidata for Databus"
echo "----------------------------"

cd $BASEDIR

files=$(find wikidatawiki -name "*.ttl.bz2" | sort -u )

function exceptDataset {
        case $1 in
		"duplicate-iri-split") echo "debug";;
                "r2r-mapping-errors") echo "debug";;
                "type-like-statements") echo "debug";;

                *) echo "$1";;
        esac
}

function exceptName {
        case $1 in
                "duplicate-iri-split") echo "debug_duplicateirisplit";;
                "r2r-mapping-errors") echo "debug_r2rmappingerrors";;
                "type-like-statements") echo "debug_typelikestatements";;

		*) echo "$1";;
        esac
}

for file in $files; do

	name=${file##*/}; name=$(echo $name | cut -d"." -f1)
	dumpVersion=${file%/*}; dumpVersion=${dumpVersion##*/}
	version="${dumpVersion:0:4}.${dumpVersion:4:2}.${dumpVersion:6:2}"

	CONTVAR=""
	if [[ $name == *"-nmw"* ]]; then
                CONTVAR="${CONTVAR}_nmw"
        fi
        if [[ $name == *"-reified"* ]]; then
                CONTVAR="${CONTVAR}_reified"
        fi
        if [[ $name == *"-reified-qualifiers"* ]]; then
                CONTVAR="${CONTVAR}_qualifiers"
        fi
        if [[ $name == *"-redirected"* ]]; then
                CONTVAR="${CONTVAR}_redirected"
	fi
        if [[ $name == *"-length"* ]]; then
                CONTVAR="${CONTVAR}_length"
        fi
        if [[ $name == *"-ids"* ]]; then
                CONTVAR="${CONTVAR}_ids"
        fi
        if [[ $name == *"-uris"* ]]; then
                CONTVAR="${CONTVAR}_uris"
        fi
        if [[ $name == *"-transitive"* ]]; then
                CONTVAR="${CONTVAR}_transitive"
        fi
	dataset=$(echo $name | sed -e "s/wikidatawiki-$dumpVersion-//g; s/-nmw//g; s/wikidata-//g; s/-reified//g; s/-qualifiers//g; s/-redirected//g; s/-ids//g; s/-length//g; s/-uris//g; s/-transitive//g; s/transitive-//g")
	new_name="${dataset}${CONTVAR}"

	if [[ $dataset == *"interlanguage-links"* ]]; then
		new_name="interlanguange-links_lang="$(echo $dataset | sed "s/interlanguage-links-//g")
		dataset="interlanguange-links"
	fi

	dataset=$(exceptDataset $dataset)
	new_name=$(exceptName $new_name)

	new_name=$new_name$(echo ${file##*/} | sed "s/$name//g")

	mkdir -p $DATABUSMVNPOMDIR/$dataset/$version/
	cp -vn  $file $DATABUSMVNPOMDIR/$dataset/$version/$new_name
done
