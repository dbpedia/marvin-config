# Topical-concepts dataset

This dataset contains extracted DBpedia Resources that are main articles of the categories.

Extractor that produces topical-concepts dataset: `TopicalConceptsExtractor`

### Changelog

* [2021.09.01] Fix issue https://github.com/dbpedia/extraction-framework/issues/711. Remove the triple starting with `http://dbpedia.org/resource/Pininfarina`. Change `dct:subject` property to `dbo:mainArticleForCategory` .
