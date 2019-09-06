# MARVIN-config

Configuration files for MARVIN on the TIB servers, public for forking the architecture

# Acknowledgements
We thank Sören Auer and the Technische Informationsbibliothek (TIB) for providing three servers to run:

* the main DBpedia extraction on a monthly basis 
* community-provided extractors on Wikipedia, Wikidata or other sources 
* enrichment, cleaning and parsing services, so-called [Databus mods](https://github.com/dbpedia/databus-mods/) for open data on the Databus

This contribution by TIB is a great push towards incentivizing Open Data and establishing a global and national research and innovation data infrastructure. 

# Workflow

## Downloading the wikimedia dumps
TODO

## Running the extraction
TODO

## Deploy on Databus
TODO

## Run Databus-Derive (clone and parse)
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
#######
# This is still manual, will be a cronjob soon
#######
su marvin-fetch
tmux a -t derive

WHAT=mappings
NEWVERSION=2019.08.30
# prepare
cd /data/derive/databus-maven-plugin/dbpedia/$WHAT
git pull
mvn versions:set -DnewVersion=$NEWVERSION
# run
mvn -T 23 databus-derive:clone -Ddatabus.deriveversion=$NEWVERSION
```

## Move data to download server (internal)
run marvin-fetch.sh script in databus/dbpedia folder

## Deploy official files


