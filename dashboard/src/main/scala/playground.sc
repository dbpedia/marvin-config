import org.apache.jena.query.QueryExecutionFactory
import org.dbpedia.release.config.Config

import scala.collection.mutable.ArrayBuffer

val versions = new ArrayBuffer[String]()
QueryExecutionFactory
  .sparqlService(
    "http://databus.dbpedia.org/repo/sparql",
    Config.versions.query
  ).execSelect()
  .forEachRemaining(row => {
    versions.append(row.get("version").asLiteral().getLexicalForm)
  })
