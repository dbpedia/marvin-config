package org.dbpedia.release.handler

import org.apache.jena.query.QueryExecutionFactory
import org.dbpedia.release.config.Config
import org.dbpedia.release.model.ArtifactStatus

import scala.collection.mutable.ListBuffer

object CompletenessHandler {

  private def getQuery(publisherName: String, group: String, version: String): Option[String] = {
    if(publisherName == "marvin")
    group match {
      case "mappings" => Some(Config.completeness.query.marvin.mappings(version))
      case "generic" => Some(Config.completeness.query.marvin.generic(version))
      case "wikidata" => Some(Config.completeness.query.marvin.wikidata(version))
      case _ => None
    }
    else if(publisherName == "dbpedia")
      group match {
        case "mappings" => Some(Config.completeness.query.dbpedia.mappings(version))
        case "generic" => Some(Config.completeness.query.dbpedia.generic(version))
        case "wikidata" => Some(Config.completeness.query.dbpedia.wikidata(version))
        case _ => None
      }
    else
      None
  }

  def getStatus(publisherName: String, group: String, version: String): Option[List[ArtifactStatus]] = {
    try {
      getQuery(publisherName, group, version).map(query => {
        val buffer = new ListBuffer[ArtifactStatus]
        val exec = QueryExecutionFactory
          .sparqlService("https://databus.dbpedia.org/repo/sparql", query)
        exec.execSelect()
          .forEachRemaining(resRow => {
            val expectedFiles = resRow.get("?expected_files").asLiteral().getLexicalForm.toInt
            val actualFiles = resRow.get("?actual_files").asLiteral().getLexicalForm.toInt
            val artifact = resRow.get("?artifact").asResource().getURI.split("/").last
            buffer.append(ArtifactStatus(group, artifact.toString, version, expectedFiles, actualFiles))
          })
        exec.close()
        buffer.toList
      })
    } catch {
      case _: Exception => None
    }
  }

  def main(args: Array[String]): Unit = {

    getStatus("marvin", "wikidata", "2020.03.01").foreach(_.foreach(x => println(x.artifact, x.actual, x.expected)))
  }

}
