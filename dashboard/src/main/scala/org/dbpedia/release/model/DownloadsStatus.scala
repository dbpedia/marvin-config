package org.dbpedia.release.model

object DownloadsStatus {

  def apply(group: String, done: List[String], failed: List[String]): Option[DownloadsStatus] = {

    Some(new DownloadsStatus(done, List(), failed))
  }

}

case class DownloadsStatus(done: List[String], waiting: List[String], failed: List[String])

