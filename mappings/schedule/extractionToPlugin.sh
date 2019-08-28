#!/bin/bash

extraction_data="/data/extraction/wikidumps/"
databus_folder="/data/extraction/databus-maven-plugin/dbpedia/"
#databus_maven_plugin_structure="src/main/databus"
databus_maven_plugin_structure=""


# @ALL|@GENERIC|@MAPPINGS or seperated by SPACE
artifacts="@MAPPINGS"
filter_extension=".ttl.*"

group="mappings"
rapper=false

tmp_folder="$databus_folder/tmp/"

# --- FUNC ---

# zh_yue to yue, zh_min_nan to nan, bat_smg to batsmg
function name_to_variant {
	case $1 in
		"zh_yue") echo "lang=yue";;
		"zh_min_nan") echo "lang=nan";;
		"bat_smg") echo "lang=batsmg";;
		"commons") echo "commons";;
		*) echo "lang=$1";;
	esac
}

# mv instance-types-transitive in instance-types
function merge_to_artifact {
	case $1 in
		"instance-types-transitive") echo "instance-types";;
		*) echo $1;;
	esac
}

function additional_content_variants {
	case $1 in
		"instance-types-transitive") echo "_transitive";;
		*) echo "";;
	esac
}

function process_file {
	echo "processing: $1"
	if [ $rapper = true ]; then
		# debug-artifact
		if [ ! -d $databus_folder/debug/debug_$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version/  ]; then
			mkdir -p $databus_folder/debug/debug-$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version/
		fi

                if [ ! -d $tmp_folder/$(merge_to_artifact $artifact)/$version/ ]; then
                        mkdir -p $tmp_folder/$(merge_to_artifact $artifact)/$version/
                        mkdir -p $tmp_folder/$(merge_to_artifact $artifact)/$version/sort/
                fi

                debug_pipe="$tmp_folder/$(merge_to_artifact $artifact)/$version/${content_variant}_debug.pipe"
                if [ ! -f $debug_pipe ]; then
			mkfifo $debug_pipe
                fi

		debug_file_path="$databus_folder/debug/debug-$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version/debug-$(merge_to_artifact $artifact)_${content_variant}_debug=rapper.bz2"

		tmpfile=$tmp_folder/$(merge_to_artifact $artifact)/$version/$content_variant

		lbzip2 -dc $1 \
		| rapper -i ntriples -O - - file 2>>$debug_pipe \
		| ascii2uni -a U 2>>$debug_pipe  \
		| LC_ALL=C sort --parallel=4 -u -T $tmp_folder/$(merge_to_artifact $artifact)/$version/sort/ \
		| lbzip2 > $tmpfile &

		lbzip2 -c < $debug_pipe > $debug_file_path

		mv $tmpfile $2;
		rm $debug_pipe
	else
		#cp -vn $1 $2
		pv $1 > $2
	fi
}

function prepare_databus_artifacts {
	echo "prepare: $1"
	for artifact in $1; do
		for file_path in $(find $extraction_data -name "*[0-9]-$artifact$filter_extension"); do
			#echo "preparing: $file_path"

			file="${file_path##*/}"

			dump_version="${file_path%/*}"
			dump_version="${dump_version##*/}"

			version="${dump_version:0:4}.${dump_version:4:2}.${dump_version:6:2}"

			content_variant="$(name_to_variant ${file%%wiki-*})$(additional_content_variants $artifact)"

			new_file="$(merge_to_artifact $artifact)_$content_variant.${file#*.}"

			# folder check
			if [ ! -d $databus_folder/$group/$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version/ ]; then
				mkdir -p $databus_folder/$group/$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version
			fi

			new_file_path="$databus_folder/$group/$(merge_to_artifact $artifact)/$databus_maven_plugin_structure/$version/$new_file"

			if [ -f $new_file_path ]; then
				echo "skipping $file_path"
			else
				process_file $file_path $new_file_path
			fi

		done
		echo "artifact: $artifact"
	done
}

# --- MAIN ---

case $artifacts in
	"@MAPPINGS")
		prepare_databus_artifacts "instance-types instance-types-transitive mappingbased-literals mappingbased-objects-uncleaned specific-mappingbased-properties geo-coordinates-mappingbased" ;;
	"@GENERIC")
		echo "TODO prepare: @GENERIC" ;;
	"@ALL")
		echo "TODO prepare: @ALL" ;;
	*)
		prepare_databus_artifacts $artifacts ;;
esac

