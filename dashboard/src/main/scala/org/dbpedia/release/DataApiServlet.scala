package org.dbpedia.release

import java.text.SimpleDateFormat
import java.util.Calendar

import org.apache.jena.query.{QueryException, QueryExecutionFactory}
import org.dbpedia.release.config.Config
import org.dbpedia.release.config.Config.versions
import org.dbpedia.release.handler.{CompletenessHandler, InputDumpHandler, ReleaseLogHandler}
import org.dbpedia.release.model.VersionStatus
import org.json4s.{DefaultFormats, Formats}
import org.scalatra._
import org.scalatra.json.JacksonJsonSupport
import org.slf4j.LoggerFactory

import scala.collection.mutable.{ArrayBuffer, ListBuffer}


// Swagger support
import org.scalatra.swagger._

// JSON-related libraries
import org.json4s.{DefaultFormats, Formats}

// JSON handling support from Scalatra
import org.scalatra.json._

class DataApiServlet(implicit val swagger: Swagger)
  extends ScalatraServlet with JacksonJsonSupport with SwaggerSupport {

  protected val applicationDescription = "applicationDescription"

  private val log = LoggerFactory.getLogger(classOf[DataApiServlet])

  before() {
    contentType = formats("json")
  }

  protected implicit val jsonFormats: Formats = DefaultFormats

  get("/release/versions") {

    val versions = new ListBuffer[VersionStatus]()
    val qexec = QueryExecutionFactory
      .sparqlService(
        "http://databus.dbpedia.org/repo/sparql",
        Config.versions.query
      )
    qexec.execSelect()
      .forEachRemaining(row => {
        versions.append(VersionStatus(row.get("version").asLiteral().getLexicalForm,2))
      })
    qexec.close()

    val latestOnBus = versions.map(_.version).max
    val latestPossible = new SimpleDateFormat("y.MM").format(Calendar.getInstance().getTime) + ".01"

    if (latestOnBus < latestPossible)
      VersionStatus(latestPossible,0) :: versions.toList
    else
      versions.toList
  }

  get("/release/logs/:group/:version") {
    val group = params("group")
    val version = params("version").replace(".", "-")

    ReleaseLogHandler.getLogFiles(group, version) match {
      case Some(array) => array.toList
      case _ => List()
    }
  }

  get("/release/downloads/:group/:version") {
    val group = params("group")
    val version = params("version")

    InputDumpHandler.getDownloadChecks(group,version) match {
      case Some(states) => states
      case _ => "{}"
    }
  }

  get("/release/completeness/:publisherName/:group/:version") {
    val group = params("group")
    val version = params("version")
    val publisherName = params("publisherName")

    CompletenessHandler.getStatus(publisherName, group, version) match {
      case Some(success) => success
      case _ => List()
    }
  }

  private val getVersions =
    apiOperation[VersionResponse]("versionsByGroup")
      .summary("Show all versions")
      .parameter(
        pathParam[String]("group")
          .description("Group to search for")
      )
      .result

  /**
   *
   */
  get("/release/versions/:group", operation(getVersions)) {

    val group = params("group")

    val marvinVersions = new ArrayBuffer[String]()
    val dbpediaVersions = new ArrayBuffer[String]()

    QueryExecutionFactory
      .sparqlService(
        "http://databus.dbpedia.org/repo/sparql",
        Queries.versionQuery(group)
      ).execSelect()
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

    log.info("\n" + query)

    val response = new ArrayBuffer[CompletenessResponse]()

    QueryExecutionFactory
      .sparqlService("http://databus.dbpedia.org/repo/sparql", query)
      .execSelect()
      .forEachRemaining(row => {
        val artifact = row.get("artifact").asResource().getURI
        val version = row.get("versionString").asLiteral().getLexicalForm
        val actualFiles = row.get("actual_files").asLiteral().getLexicalForm
        val expectedFiles = row.get("expected_files").asLiteral().getLexicalForm

        response.append(CompletenessResponse(artifact, version, actualFiles, expectedFiles))
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
