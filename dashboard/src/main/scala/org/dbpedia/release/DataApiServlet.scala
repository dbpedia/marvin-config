package org.dbpedia.release

import org.apache.jena.query.{QueryException, QueryExecutionFactory}
import org.json4s.{DefaultFormats, Formats}
import org.scalatra._
import org.scalatra.json.JacksonJsonSupport
import org.slf4j.LoggerFactory

import scala.collection.mutable.ArrayBuffer


// JSON-related libraries
import org.json4s.{DefaultFormats, Formats}

// JSON handling support from Scalatra
import org.scalatra.json._

class DataApiServlet extends ScalatraServlet with JacksonJsonSupport {

  val log = LoggerFactory.getLogger(classOf[DataApiServlet])

  before() {
    contentType = formats("json")
  }

  protected implicit val jsonFormats: Formats = DefaultFormats

  /**
   *
   */
  get("/release/versions/:group") {

    val group = params("group")

    val marvinVersions = new ArrayBuffer[String]()
    val dbpediaVersions = new ArrayBuffer[String]()

    QueryExecutionFactory
      .sparqlService("http://databus.dbpedia.org/repo/sparql", Queries.versionQuery(group))
      .execSelect()
      .forEachRemaining(row => {
        val version = row.get("?version").asLiteral().getLexicalForm
        val account = row.get("account").asResource().getURI
        if ("https://databus.dbpedia.org/marvin" == account)
          marvinVersions.append(version)
        else {
          dbpediaVersions.append(version)
        }
      })

    VersionResponse(group, marvinVersions.toList, dbpediaVersions.toList)
  }

  /**
   * source files completeness for given release
   */
  get("/check-download/:account/:group/:artifact/:version") {
    "TODO"
  }

  /**
   * target files completeness for given release
   */
//  get("/check-release/:account/:group/:artifact/:version") {
  get("/check-release/:group") {

    val group = params("group")

    val query = {
      group match {
        case "mappings" => Queries.complMappings()
        case "generic" => ""
        case "wikidata" => ""
        case "text" => ""
      }
    }

    log.info("\n"+query)

    val response = new ArrayBuffer[CompletenessResponse]()

    QueryExecutionFactory
      .sparqlService("http://databus.dbpedia.org/repo/sparql", query)
      .execSelect()
      .forEachRemaining(row => {
        val artifact  = row.get("artifact").asResource().getURI
        val version  = row.get("versionString").asLiteral().getLexicalForm
        val actualFiles  = row.get("actual_files").asLiteral().getLexicalForm
        val expectedFiles = row.get("expected_files").asLiteral().getLexicalForm

        response.append(CompletenessResponse(artifact,version,actualFiles,expectedFiles))
      })

    response.toList
  }

  /**
   * log state for given release
   */
  get("/check-logs/:account/:group/:artifact/:version") {
    "TODO"
  }
}
