# Long abstracts from Wikipedia articles
The text before the table of contents of Wikipedia articles

Using the property `dbo:abstract` all content before the table of contents is extracted. 

Extractor that produces long abstracts: `HtmlAbstractExtractor`

### Changelog:
+ Fix issue https://github.com/dbpedia/extraction-framework/issues/693. Brackets that starts with `(;`, `(,` are removed during abstract extraction. Empty brackets like `()`, `( )` are also removed. `remove-broken-brackets-html-abstracts=true` is a property which enable removing those brackets.
+ Fix issue https://github.com/dbpedia/extraction-framework/issues/579. Added extraction of transcriptions by removing  `.noexcerpt` from `nif-remove-elements` list in the `nifextractionconfig.json` file.
