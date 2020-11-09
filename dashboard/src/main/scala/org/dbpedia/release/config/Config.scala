package org.dbpedia.release.config

import java.net.URL

/**
 * Dashboard config
 */
object Config {

  object versions {

    val query: String =
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

      object dbpedia {

        def mappings(version: String): String =
          s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
             |PREFIX dct:    <http://purl.org/dc/terms/>
             |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
             |
             |SELECT ?expected_files ?actual_files ?delta ?artifact {
             |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
             |      VALUES (?artifact ?expected_files) {
             |( <https://databus.dbpedia.org/dbpedia/mappings/geo-coordinates-mappingbased> 29 )
             |( <https://databus.dbpedia.org/dbpedia/mappings/instance-types> 80 )
             |( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-literals> 40 )
             |( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-objects> 120 )
             |( <https://databus.dbpedia.org/dbpedia/mappings/mappingbased-objects-uncleaned> 40 )
             |( <https://databus.dbpedia.org/dbpedia/mappings/specific-mappingbased-properties> 40 )
             |    }
             |    ?dataset dataid:artifact ?artifact .
             |    ?dataset dct:hasVersion ?versionString .
             |    ?dataset dcat:distribution ?distribution .
             |    FILTER(str(?versionString) = '$version')
             |  } GROUP BY ?artifact ?expected_files ?actual_files }
             |  #FILTER(?delta != 0)
             |}
             |""".stripMargin

        def generic(version: String): String =
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
             |( <https://databus.dbpedia.org/marvin/generic/geo-coordinates> 139 )
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
             |( <https://databus.dbpedia.org/dbpedia/wikidata/alias> 2 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/debug> 3 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/description> 2 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/geo-coordinates> 1 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/images> 1 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/instance-types> 2 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/labels> 2 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/mappingbased-literals> 1 )
             |( <https://databus.dbpedia.org/dbpedia/wikidata/mappingbased-objects-uncleaned> 1 )
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
             |  #FILTER(?delta != 0)
             |}
             |""".stripMargin
      }

      object marvin {

        def mappings(version: String): String =
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

        def generic(version: String): String =
          s"""PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
             |PREFIX dct:    <http://purl.org/dc/terms/>
             |PREFIX dcat:   <http://www.w3.org/ns/dcat#>
             |
             |SELECT ?expected_files ?actual_files ?delta ?artifact {
             |  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
             |      VALUES (?artifact ?expected_files) {
             |( <https://databus.dbpedia.org/marvin/generic/anchor-text> 1 )
             |( <https://databus.dbpedia.org/marvin/generic/article-templates> 278 )
             |( <https://databus.dbpedia.org/marvin/generic/categories> 417 )
             |( <https://databus.dbpedia.org/marvin/generic/citations> 2 )
             |( <https://databus.dbpedia.org/marvin/generic/commons-sameas-links> 7 )
             |( <https://databus.dbpedia.org/marvin/generic/disambiguations> 15 )
             |( <https://databus.dbpedia.org/marvin/generic/external-links> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/geo-coordinates> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/homepages> 13 )
             |( <https://databus.dbpedia.org/marvin/generic/infobox-properties> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/infobox-property-definitions> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/interlanguage-links> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/labels> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/page> 278 )
             |( <https://databus.dbpedia.org/marvin/generic/persondata> 4 )
             |( <https://databus.dbpedia.org/marvin/generic/redirects> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/revisions> 278 )
             |( <https://databus.dbpedia.org/marvin/generic/topical-concepts>11 )
             |( <https://databus.dbpedia.org/marvin/generic/wikilinks> 139 )
             |( <https://databus.dbpedia.org/marvin/generic/wikipedia-links> 139 )
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

  }

  object extractionInput {

    // TODO handle batsmg nan yue
    def wikisByGroup(group: String): List[String] = group match {
      case "mappings" => List(
        "ar", "az", "be", "bg", "bn", "ca", "commons", "cs", "cy", "de", "el", "en", "eo", "es", "eu", "fr", "ga", "gl", "hi", "hr", "hu",
        "hy", "id", "it", "ja", "ko", "lv", "mk", "nl", "pl", "pt", "ro", "ru", "sk", "sl", "sr", "sv", "tr", "uk", "vi"
      )
      case "generic" => List(
        "af", "als", "am", "an", "ar", "arz", "ast", "az", "azb", "ba", "bar", "bat_smg", "be", "bg", "bn", "bpy", "br",
        "bs", "bug", "ca", "cdo", "ce", "ceb", "ckb", "commons", "cs", "cv", "cy", "da", "de", "el", "eml", "en", "eo",
        "es", "et", "eu", "fa", "fi", "fo", "fr", "fy", "ga", "gd", "gl", "gu", "he", "hi", "hr", "hsb", "ht", "hu",
        "hy", "ia", "id", "ilo", "io", "is", "it", "ja", "jv", "ka", "kk", "kn", "ko", "ku", "ky", "la", "lb", "li",
        "lmo", "lt", "lv", "mai", "mg", "mhr", "min", "mk", "ml", "mn", "mr", "mrj", "ms", "my", "mzn", "nap", "nds",
        "ne", "new", "nl", "nn", "no", "oc", "or", "os", "pa", "pl", "pms", "pnb", "pt", "qu", "ro", "ru", "sa", "sah",
        "scn", "sco", "sd", "sh", "si", "simple", "sk", "sl", "sq", "sr", "su", "sv", "sw", "ta", "te", "tg", "th",
        "tl", "tr", "tt", "uk", "ur", "uz", "vec", "vi", "vo", "wa", "war", "wuu", "xmf", "yi", "yo", "zh",
        "zh_min_nan", "zh_yue",
      )
      case "wikidata" => List(
        "wikidata"
      )
      case _ => List()
    }

    object downloadCheckUrl {
      val mappings = new URL("http://dbpedia-mappings.tib.eu/logs/download-checks/")
      val generic = new URL("http://dbpedia-mappings.tib.eu/logs/download-checks/")
      val wikidata = new URL("http://dbpedia-wikidata.tib.eu/logs/download-checks/")
    }

  }

  object extractionLogs {

    object baseUrl {
      val mappings = new URL("http://dbpedia-mappings.tib.eu/logs/mappings/")
      val generic = new URL("http://dbpedia-mappings.tib.eu/logs/generic/")
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

    val descriptionsBylogName = Map(
      name.downloadMappings -> "Download of latest mappings from <a href=\"http://mappings.dbpedia.org\">mappings.dbpedia.org</a>",
      name.downloadOntology -> "Download of latest DBpedia ontology",
      name.downloadWikidumps -> "Download of latest Wiki-Dumps from <a href=\"http://dumps.wikimedia.org\">dumps.wikimedia.org</a>",
      name.extraction -> "DIEF extraction process",
      name.postProcess -> "Post-processing of redirects and more",
      name.unredirected -> "Files with unresolved redirects (pre post-processing)"
    )

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
