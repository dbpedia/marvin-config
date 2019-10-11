# MARVIN-config

MARVIN is the release bot that does automated DBpedia releases each month on three different servers for generic, mappings, wikidata, abstract extraction. 
The repository at https://git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config can be used to fork the architecture for creating extensions, developing new extractors or debugging old ones. 
Fixes and patches will be manually deployed via a freah `git clone` from the `master` branch of the [DBpedia Extraction Framework](https://github.com/dbpedia/extraction-framework/). 

## Contributions & License
All scripts and config files in this repo are CC-0 (Public Domain). 
We accept pull requests to improve the config files, all contributions will be merged as CC-0. 

## Run a MARVIN extraction
```
git clone https://git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config
cd marvin-config
# Romanian extraction, very small
./marvin_extraction_run.sh --group=test
```

To run the other extractions, use either
```
# around 4-7 days
./marvin_extraction_run.sh --group=generic
# around 4-7 days
./marvin_extraction_run.sh --group=mappings
# around 7-14 days
./marvin_extraction_run.sh --group=wikidata
```

## Cronjobs

Below is a list


## Acknowledgements
We thank Sören Auer and the Technische Informationsbibliothek (TIB) for providing three servers to run:

* the main DBpedia extraction on a monthly basis 
* community-provided extractors on Wikipedia, Wikidata or other sources 
* enrichment, cleaning and parsing services, so-called [Databus mods](https://github.com/dbpedia/databus-mods/) for open data on the Databus

This contribution by TIB to DBpedia & its community is a great push towards incentivizing Open Data and establishing a global and national research and innovation data infrastructure. 

# Workflow

## Downloading the wikimedia dumps
TODO

## Update and Run the extraction
TODO

## Deploy MARVIN on Databus
TODO

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

