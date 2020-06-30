package org.dbpedia.release.handler

import org.apache.jena.query.QueryExecutionFactory
import org.dbpedia.release.config.Config
import org.dbpedia.release.model.VersionStatus

import scala.collection.mutable.ListBuffer

object CompletenessHandler {

  private def getQuery(group: String, version: String): Option[String] = {
    group match {
      case "mappings" => Some(Config.completeness.query.mappings(version))
      case "generic" => Some(Config.completeness.query.generic(version))
      case "wikidata" => Some(Config.completeness.query.wikidata(version))
      case _ => None
    }
  }

  def getStatus(group: String, version: String): Option[Array[VersionStatus]] = {

    getQuery(group, version).map(query => {
      val arrayBuffer = new ListBuffer[VersionStatus]

      QueryExecutionFactory
        .sparqlService("https://databus.dbpedia.org/repo/sparql", query)
        .execSelect()
        .forEachRemaining(resRow => {
          val expectedFiles = resRow.get("?expected_files").asLiteral().getLexicalForm.toInt
          val actualFiles = resRow.get("?actual_files").asLiteral().getLexicalForm.toInt
          val artifact = resRow.get("?artifact").asResource().getURI.split("/").last
          arrayBuffer.append(VersionStatus(group, artifact.toString, version, expectedFiles, actualFiles))
        })
      arrayBuffer.toArray
    })
  }


  def main(args: Array[String]): Unit = {

    getStatus("wikidata", "2020.03.01").foreach(_.foreach(x => println(x.artifact, x.actual, x.expected)))
  }

}
