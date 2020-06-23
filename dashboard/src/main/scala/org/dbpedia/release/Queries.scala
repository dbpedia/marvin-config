package org.dbpedia.release

object Queries {

  def versionQuery(group: String): String =
    s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
       |PREFIX dct:    <http://purl.org/dc/terms/>
       |
       |SELECT DISTINCT ?account ?group ?version WHERE {
       |  VALUES ?group {
       |    <https://databus.dbpedia.org/marvin/$group>
       |    <https://databus.dbpedia.org/dbpedia/$group>
       |  }
       |  ?s a              dataid:Dataset .
       |  ?s dataid:account ?account .
       |  ?s dataid:group   ?group .
       |  ?s dct:hasVersion ?version .
       |}
       |ORDER BY DESC(?version)
       |""".stripMargin

  def complMappings(): String =
    s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
       |PREFIX dct:    <http://purl.org/dc/terms/>
       |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
       |
       |SELECT * {
       |{SELECT ?expected_files (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?versionString ?artifact {
       |      VALUES (?artifact ?expected_files) {
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/geo-coordinates-mappingbased> 29 )
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/instance-types> 80 )
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-literals> 40 )
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-objects> 120 )
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-objects-uncleaned> 40 )
       |        ( <https://databus.dbpedia.org/dbpedia/mappings/specific-mappingbased-properties> 40 )
       |    }
       |    ?dataset dataid:artifact ?artifact .
       |    ?dataset dataid:version ?versionIRI .
       |    ?dataset dct:hasVersion ?versionString .
       |    ?dataset dcat:distribution ?distribution .
       |} GROUP BY ?versionString ?artifact ?expected_files ?actual_files}
       |  FILTER(?delta != 0)
       |} ORDER BY DESC(?versionString)
       |""".stripMargin
}
