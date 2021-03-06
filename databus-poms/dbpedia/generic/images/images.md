# Images dataset
contains URLs and basic metadata about images included in Wikipedia articles

The dataset uses several properties to specify the relation between image entities and DBpedia entities.
`dbo:thumbnail` connects the first image from the wikipage as thumbnail (donwload url width parameter set to 300 pixels) to the DBpedia entity. 
In contrast, `foaf:depiction` connects the URLs of all images (no information on the order of appearance is given) in full size to a DBpedia entity.

However, `foaf:thumbnail` is used to connect the thumbnail URL to the image entity. The subject of the image entity is the download / export API link and uses  
 `rdf:type`, `dc:rights` for basic metadata.


Examples of triples:

```
#DBpedia entity
<http://dbpedia.org/resource/Joe_Biden> <http://xmlns.com/foaf/0.1/depiction> <http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg> .
<http://dbpedia.org/resource/Joe_Biden> <http://dbpedia.org/ontology/thumbnail> <http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg?width=300> .

# Image entities
<http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg> <http://xmlns.com/foaf/0.1/thumbnail> <http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg?width=300> .
<http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://dbpedia.org/ontology/Image> .
<http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg> <http://purl.org/dc/elements/1.1/rights> <http://en.wikipedia.org/wiki/File:Joe_Biden_presidential_portrait.jpg> .

# Thumbnail entities
<http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg?width=300> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://dbpedia.org/ontology/Image> .
<http://commons.wikimedia.org/wiki/Special:FilePath/Joe_Biden_presidential_portrait.jpg?width=300> <http://purl.org/dc/elements/1.1/rights> <http://en.wikipedia.org/wiki/File:Joe_Biden_presidential_portrait.jpg> .

```


### Changelog

* [2021.12.01] Fixed producing image triples from pages that don't contain images. Fixed extracting images that are not related to the wikipages (Commits: [5b984fc7](https://github.com/dbpedia/extraction-framework/commit/5b984fc7d9f61822a9b017b85f6b2546c15e1370), [5b984fc](https://github.com/dbpedia/extraction-framework/commit/5b984fc7d9f61822a9b017b85f6b2546c15e1370), [ebc6c61](https://github.com/dbpedia/extraction-framework/commit/ebc6c6184679cfdea0c1648bae593a580dd8d7cc)). Related issue: https://github.com/dbpedia/extraction-framework/issues/720
