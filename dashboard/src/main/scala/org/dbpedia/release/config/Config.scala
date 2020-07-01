package org.dbpedia.release.config

import java.net.URL
import java.text.SimpleDateFormat
import java.util.Calendar

import org.apache.jena.query.QueryExecutionFactory

import scala.collection.mutable.ListBuffer

/**
 * Dashboard config
 */
object Config {

  object versions {

    val query : String =
      """PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
        |PREFIX dct:    <http://purl.org/dc/terms/>
        |
        |SELECT DISTINCT ?version WHERE {
        |  VALUES ?publisher { <https://databus.dbpedia.org/marvin> }
        |  ?s a dataid:Dataset.
        |  ?s dataid:account ?publisher .
        |  ?s dct:hasVersion ?version .
        |
        |} ORDER BY DESC(?version)
        |""".stripMargin
  }

  object completeness {

    object query {

      def mappings(version:String): String =
        s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
           |PREFIX dct:    <http://purl.org/dc/terms/>
           |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
           |
           |SELECT ?expected_files ?actual_files ?delta ?artifact {
           |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
           |      VALUES (?artifact ?expected_files) {
           |( <https://databus.dbpedia.org/marvin/mappings/geo-coordinates-mappingbased> 29 )
           |( <https://databus.dbpedia.org/marvin/mappings/instance-types> 80 )
           |( <https://databus.dbpedia.org/marvin/mappings/mappingbased-literals> 40 )
           |( <https://databus.dbpedia.org/marvin/mappings/mappingbased-objects> 120 )
           |( <https://databus.dbpedia.org/marvin/mappings/mappingbased-objects-uncleaned> 40 )
           |( <https://databus.dbpedia.org/marvin/mappings/specific-mappingbased-properties> 40 )
           |    }
           |    ?dataset dataid:artifact ?artifact .
           |    ?dataset dct:hasVersion ?versionString .
           |    ?dataset dcat:distribution ?distribution .
           |    FILTER(str(?versionString) = '$version')
           |  } GROUP BY ?artifact ?expected_files ?actual_files }
           |  #FILTER(?delta != 0)
           |}
           |""".stripMargin

      def generic(version:String): String =
        s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
           |PREFIX dct:    <http://purl.org/dc/terms/>
           |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
           |
           |SELECT ?expected_files ?actual_files ?delta ?artifact {
           |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
           |      VALUES (?artifact ?expected_files) {
           |( <https://databus.dbpedia.org/dbpedia/generic/anchor-text> 1 )
           |( <https://databus.dbpedia.org/dbpedia/generic/article-templates> 278 )
           |( <https://databus.dbpedia.org/dbpedia/generic/categories> 417 )
           |( <https://databus.dbpedia.org/dbpedia/generic/citations> 2 )
           |( <https://databus.dbpedia.org/dbpedia/generic/commons-sameas-links> 7 )
           |( <https://databus.dbpedia.org/dbpedia/generic/disambiguations> 15 )
           |( <https://databus.dbpedia.org/dbpedia/generic/external-links> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/geo-coordinates> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/homepages> 13 )
           |( <https://databus.dbpedia.org/dbpedia/generic/infobox-properties> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/infobox-property-definitions> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/interlanguage-links> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/labels> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/page> 278 )
           |( <https://databus.dbpedia.org/dbpedia/generic/persondata> 4 )
           |( <https://databus.dbpedia.org/dbpedia/generic/redirects> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/revisions> 278 )
           |( <https://databus.dbpedia.org/dbpedia/generic/topical-concepts>11 )
           |( <https://databus.dbpedia.org/dbpedia/generic/wikilinks> 139 )
           |( <https://databus.dbpedia.org/dbpedia/generic/wikipedia-links> 139 )
           |    }
           |    ?dataset dataid:artifact ?artifact .
           |    ?dataset dct:hasVersion ?versionString .
           |    ?dataset dcat:distribution ?distribution .
           |    FILTER(str(?versionString) = '$version')
           |  } GROUP BY ?artifact ?expected_files ?actual_files }
           |  #FILTER(?delta != 0)
           |}
           |""".stripMargin

      def wikidata(version: String): String =
        s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
           |PREFIX dct:    <http://purl.org/dc/terms/>
           |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
           |
           |SELECT ?expected_files ?actual_files ?delta ?artifact {
           |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
           |      VALUES (?artifact ?expected_files) {
           |( <https://databus.dbpedia.org/marvin/wikidata/alias> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/debug> 3 )
           |( <https://databus.dbpedia.org/marvin/wikidata/description> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/geo-coordinates> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/images> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/instance-types> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/labels> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-literals> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-objects-uncleaned> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-properties-reified> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/ontology-subclassof> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/page> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/properties> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/redirects> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/references> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/revision> 2 )
           |( <https://databus.dbpedia.org/marvin/wikidata/sameas-all-wikis> 1 )
           |( <https://databus.dbpedia.org/marvin/wikidata/sameas-external> 1 )
           |    }
           |    ?dataset dataid:artifact ?artifact .
           |    ?dataset dct:hasVersion ?versionString .
           |    ?dataset dcat:distribution ?distribution .
           |    FILTER(str(?versionString) = '$version')
           |  } GROUP BY ?artifact ?expected_files ?actual_files }
           |  #FILTER(?delta != 0)
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
