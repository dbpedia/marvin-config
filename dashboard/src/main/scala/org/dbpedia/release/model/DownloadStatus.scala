package org.dbpedia.release.model

object DownloadStatus extends Enumeration {
  type DownlaodStatus = Value
  val DONE: Value = Value(2)
  val FAIL: Value = Value(1)
  val WAIT: Value = Value(0)

//  def max(a: DownloadStatus.Value, b: DownloadStatus.Value): DownloadStatus.Value = {
//    if(a.id < b.id) b
//    else a
//  }
}

case class DownloadStatus(lang: String, state: DownloadStatus.Value)