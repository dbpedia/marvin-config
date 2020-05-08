# Retrieval of Code Links

Query at https://databus.dbpedia.org/yasgui/

```
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
PREFIX dataid-cv: <http://dataid.dbpedia.org/ns/cv#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX dcat:  <http://www.w3.org/ns/dcat#>
prefix dataid-debug: <http://dataid.dbpedia.org/ns/debug.ttl#> 

# Get all files
SELECT  ?artifact ?codelink WHERE {
 	?dataset dataid:group ?group .
 	?dataset dataid:artifact ?artifact .
    FILTER (?group in (<https://databus.dbpedia.org/dbpedia/wikidata>, <https://databus.dbpedia.org/dbpedia/mappings>, <https://databus.dbpedia.org/dbpedia/text>,  <https://databus.dbpedia.org/dbpedia/generic>)) .
    #FILTER NOT EXISTS {?dataset dataid-debug:codeReference ?codelink .} 
    OPTIONAL {?dataset dataid-debug:codeReference ?codelink .}
    ?dataset  dct:hasVersion  "2020.03.01"^^xsd:string . 
	
}
```
