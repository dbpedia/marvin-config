package org.dbpedia.release.handler

import java.io.{BufferedReader, InputStreamReader}
import java.net.URL
import java.util.stream.Stream

import org.dbpedia.release.config.Config
import org.dbpedia.release.model.LogFile

import scala.util.matching.Regex

object ReleaseLogHandler {

  private def getLogsUrl(group: String): Option[URL] = {
    group match {
      case "mappings" => Some(Config.extractionLogs.baseUrl.mappings)
      case "generic" => Some(Config.extractionLogs.baseUrl.generic)
      case "wikidata" => Some(Config.extractionLogs.baseUrl.wikidata)
      case _ => None
    }
  }

  private val HrefPattern: Regex = ".*<a href=\"([a-zA-Z]\\S*)\">.*".r

  def getLogFiles(group: String, version: String): Option[Array[LogFile]] = {
    try {
      getLogsUrl(group).map((baseUrl: URL) => {
        val remote: Map[String, LogFile] = new BufferedReader(new InputStreamReader(
          new URL(baseUrl, version).openStream()
        )).lines().flatMap({
          case HrefPattern(fileName) =>
            println(fileName)
            LogFile.apply(new URL(baseUrl, version + "/"), fileName) match {
              case Some(logFile) => Stream.of(logFile)
              case _ => Stream.of()
            }
          case _ => Stream.of()
        }).toArray[LogFile](size => new Array[LogFile](size)).map(lf => {
          lf.logName -> lf
        }).toMap

        Config.extractionLogs.names.map(logName => remote.getOrElse(logName, LogFile("", logName, "WAIT")))
      })
    } catch {
      case _: Exception => None
    }
  }

  def main(args: Array[String]): Unit = {

    val group = "wikidata"
    val version = "2020-05-01"

    val logFiles = getLogFiles(group, version)

    logFiles.foreach(_.foreach(x => println(x.logName, x.state)))
  }
}
