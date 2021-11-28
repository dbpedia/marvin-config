# Shortened abstracts from Wikipedia articles
The text before the table of contents of Wikipedia articles is shortened to approx. 2-3 sentences. 

Using the property rdfs:comment all full sentences within a certain amount of characters are saved in the different files. 
 
Extractor that produces short abstracts: `HtmlAbstractExtractor`

### Changelog:
+ Fix issue https://github.com/dbpedia/extraction-framework/issues/693. Brackets that starts with `(;`, `(,` are removed during abstract extraction. Empty brackets like `()`, `( )` are also removed. `remove-broken-brackets-html-abstracts=true` is a property which enable removing those brackets.
+ Fix issue https://github.com/dbpedia/extraction-framework/issues/579. Added extraction of transcriptions by removing  `.noexcerpt` from `nif-remove-elements` list in the `nifextractionconfig.json` file.
