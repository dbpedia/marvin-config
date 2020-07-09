package org.dbpedia.release.handler

import java.io.{BufferedReader, InputStreamReader}
import java.net.URL
import java.util.stream.Stream

import org.dbpedia.release.config.Config
import org.dbpedia.release.model.{DownloadStatus, DownloadsStatus}

import scala.collection.mutable.ListBuffer
import scala.util.matching.Regex

object InputDumpHandler {

  private def getDownloadCheckUrl(group: String): Option[URL] = {
    group match {
      case "mappings" => Some(Config.extractionInput.downloadCheckUrl.mappings)
      case "generic" => Some(Config.extractionInput.downloadCheckUrl.generic)
      case "wikidata" => Some(Config.extractionInput.downloadCheckUrl.wikidata)
      case _ => None
    }
  }

  private val HrefLink: Regex = ".*<a href=\"([a-zA-Z]\\S*)\">.*".r

  private val FailedDownload: Regex = "(.*)wiki\\.FAILED".r

  private val SucceededDownload: Regex = "(.*)wiki\\.SUCCESS".r

  def getDownloadChecks(group: String, version: String): Option[DownloadsStatus] = {
    try {
      getDownloadCheckUrl(group).map((downloadCheckUrl: URL) => {

        val done = new ListBuffer[String]
        //val wait = new ListBuffer[String]
        val fail = new ListBuffer[String]
        val expected = Config.extractionInput.wikisByGroup(group).toSet

        val remoteStates = new BufferedReader(new InputStreamReader(
          new URL(downloadCheckUrl, version + "/").openStream()
        )).lines().flatMap({
          case HrefLink(fileName) =>
            fileName match {
              case SucceededDownload(lang) => Stream.of(DownloadStatus(lang, DownloadStatus.DONE))
              case FailedDownload(lang) => Stream.of(DownloadStatus(lang, DownloadStatus.FAIL))
              case e => println(e); Stream.of()
            }
          case _ => Stream.of()
        }).toArray[DownloadStatus](size => new Array[DownloadStatus](size))
          .groupBy(_.lang).foreach {
          case (lang, states) =>
            if (expected.contains(lang))
              states.map(_.state).max match {
                case DownloadStatus.DONE => done.append(lang)
                //case DownloadStatus.WAIT => wait.append(lang) // TODO if remote tracks waiting
                case DownloadStatus.FAIL => fail.append(lang)
              }
        }
        DownloadsStatus(done.toList, expected.filterNot((done ++ fail).toSet).toList, fail.toList)
      })
    } catch {
      case e: Exception => None
    }
  }

  def main(args: Array[String]): Unit = {
    getDownloadChecks("mappings", "2020.06.01")
  }
}
