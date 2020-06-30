package org.dbpedia.release.config

import java.net.URL

/**
 * Dashboard config
 */
object Config {

  object completeness {

    object query {

      def mappings(version:String): String =
        s"""
           |
           |""".stripMargin

      def generic(version:String): String =
        s"""
           |
           |""".stripMargin

      def wikidata(version: String): String =
        s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
           |PREFIX dct:    <http://purl.org/dc/terms/>
           |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
           |
           |SELECT ?expected_files ?actual_files ?delta ?artifact {
           |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
           |      VALUES (?artifact ?expected_files) {
           |( <https://databus.dbpedia.org/dbpedia/wikidata/alias> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/debug> 3 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/description> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/geo-coordinates> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/images> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/instance-types> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/labels> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/mappingbased-literals> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/mappingbased-objects-uncleaned> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/mappingbased-properties-reified> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/ontology-subclassof> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/page> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/properties> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/redirects> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/references> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/revision> 2 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/sameas-all-wikis> 1 )
           |( <https://databus.dbpedia.org/dbpedia/wikidata/sameas-external> 1 )
           |    }
           |    ?dataset dataid:artifact ?artifact .
           |    ?dataset dct:hasVersion ?versionString .
           |    ?dataset dcat:distribution ?distribution .
           |    FILTER(str(?versionString) = '$version')
           |  } GROUP BY ?artifact ?expected_files ?actual_files }
           |  FILTER(?delta != 0)
           |}
           |""".stripMargin
    }
  }

  object extractionLogs {
    object baseUrl {
      val mappings = new URL("http://dbpedia-mappings.tib.eu/logs/")
      val generic = new URL("http://dbpedia-generic.tib.eu/logs/")
      val wikidata = new URL("http://dbpedia-wikidata.tib.eu/logs/")
    }

    object name {
      val downloadMappings = "downloadMappings.log"
      val downloadOntology = "downloadOntology.log"
      val downloadWikidumps = "downloadWikidumps.log"
      val extraction = "extraction.log"
      val postProcess = "postProcess.log"
      val unredirected = "unRedirected/"
    }

    val names: Array[String] =
      Array(
        name.downloadMappings,
        name.downloadOntology,
        name.downloadWikidumps,
        name.extraction,
        name.postProcess,
        name.unredirected
      )
  }
}
