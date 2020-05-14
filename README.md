# MARVIN-config

MARVIN is the release bot that does automated DBpedia releases each month on three different servers for generic, mappings, wikidata, abstract extraction. 
[This repository](https://git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config) can be used to fork the architecture for creating extensions, developing new extractors or debugging old ones. 
Fixes and patches will be deployed on the DBpedia servers each month via a fresh `git clone` from the `master` branch of the [DIEF (DBpedia Information Extraction Framework)](https://github.com/dbpedia/extraction-framework/). 

## Contributions & License
All scripts and config files in this repo are CC-0 (Public Domain). 
We accept pull requests to improve the config files, all contributions will be merged as CC-0. 
Marvin-config is intended to bootstrap developing fixes for the DIEF.

## Run a MARVIN extraction

Implementation note: the scripts creates a folder `marvin-extraction` where the code, results and logs are. 

```
# check out this repo with all config files
git clone https://git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config
cd marvin-config


# (optional) delete previous versions of the DIEF
# (~10 minutes) install dief in marvin-extraction/extraction-framework
# if you installed it already you can run `git pull && mvn clean install` to update
rm -rf marvin-extraction/extraction-framework
./setup-or-reset-dief.sh

# test run Romanian extraction, very small
./marvin_extraction_run.sh test
```

To run the other extractions, use either of
```
# around 4-7 days
./marvin_extraction_run.sh generic
# around 4-7 days
./marvin_extraction_run.sh mappings
# around 7-14 days
./marvin_extraction_run.sh wikidata
```

To specify a different dump-date
```
# Set it in extractionConfiguration/{download|extraction}.*.properties
dump-date=20200301
```
If specified dump-date is newer as current local dumps, then adding it to `extractionConfiguration/download.*.properties` is enough
## Cronjobs

Monthly cronjobs of the databus group releases, that include the MARVIN and DBpedia (re-)release:

```
# Full Wikidata
0 0 7 * * /bin/bash -c '/data/marvin-config/release-monthly-cron.sh wikidata' >/dev/null 2>&1

# Full Generic & Mappings
0 0 7 * * /bin/bash -c '/data/marvin-config/release-monthly-cron.sh generic && /data/marvin-config/release-monthly-cron.sh mappings' >/dev/null 2>&1
```

## Acknowledgements
We thank Sören Auer and the Technische Informationsbibliothek (TIB) for providing three servers to run:

* the main DBpedia extraction on a monthly basis 
* community-provided extractors on Wikipedia, Wikidata or other sources 
* enrichment, cleaning and parsing services, so-called [Databus mods](https://github.com/dbpedia/databus-mods/) for open data on the Databus

This contribution by TIB to DBpedia & its community is a great push towards incentivizing Open Data and establishing a global and national research and innovation data infrastructure. 

# Workflow Description

## Update and Run the extraction

To run a generic, mappings, or wikidata extraction the following script will do the rest.
Its default behavior is to create all folder relative to its execution directory.
If you want to adapt some paths you can edit them inside `fucntions.sh`.

```bash
./marvin-extraction-run.sh
```
### Post-Processing
Some extractions require postprocessing. The exact setup can be found in [functions.sh](https://git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config/-/blob/master/functions.sh#L41)
More info about [post-processing](http://dev.dbpedia.org/Post-Processing).

## Deploy MARVIN on Databus


The `databus-release.sh` script contains the workflow how the extracted files are renamed and copied into a databus-maven-plugin readable structure (.e.g artfact and content variants). 
Further, which parameters are used to deploy the MARVIN relases on the databus.

```bash
./databus-release.sh
```

> **NOTE:** This scrtipt sill uses absolute paths and dependens on the private key of the publishers webid
>
> **TODO:** Refactor `./databus-release.sh`

## [Manual] Run Databus-Derive (clone and parse)
On the respective server there is a user marvin-fetch, that has access to `/data/derive` containing the pom.xml of https://github.com/dbpedia/databus-maven-plugin/tree/master/dbpedia

```
# query to get all versions fro derive in xml syntax to paste directly into pom.xml
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
SELECT distinct (?derive) WHERE {

    ?dataset dataid:group <https://databus.dbpedia.org/marvin/generic> .
    ?dataset dataid:artifact ?artifact .
    ?dataset dataid:version ?version .
    ?dataset dct:hasVersion "2019.08.30"^^xsd:string
	BIND (CONCAT("<version>",?artifact,"/${databus.deriveversion}</version>") as ?derive)
}
order by asc(?derive)
```


```
su marvin-fetch
tmux a -t derive
WHAT=mappings
NEWVERSION=2019.08.30
# prepare
cd /data/derive/databus-maven-plugin/dbpedia/$WHAT
git pull
mvn versions:set -DnewVersion=$NEWVERSION
# run
mvn databus-derive:clone -Ddatabus.deriveversion=$NEWVERSION
```

## [Manual] pull data to downloads.dbpedia.org server
run marvin-fetch.sh script in databus/dbpedia folder

```
cd /media/bigone/25TB/releases/databus-maven-plugin/dbpedia
./marvin-fetch.sh wikidata 2019.08.01

```

## Deploy cleaned files to dbpedia

```
cd /media/bigone/25TB/releases/databus-maven-plugin/dbpedia/mappings
mvn clean 
mvn validate
mvn -T 8 deploy
```

