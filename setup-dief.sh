#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/marvin-extraction"
CONFIGDIR="$ROOT/extractionConfiguration"
DIEFDIR="$ROOT/extraction-framework"

git clone "https://github.com/dbpedia/extraction-framework.git" $DIEFDIR
cd $DIEFDIR
# todo add config
#cd $ROOT && cp $ROOT/config.d/universal.properties.template $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
#sed -i -e 's,$BASEDIR,'$EXTRACTIONBASEDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;
#sed -i -e 's,$LOGDIR,'$LOGDIR',g' $EXTRACTIONFRAMEWORKDIR/core/src/main/resources/universal.properties;

mvn clean install

