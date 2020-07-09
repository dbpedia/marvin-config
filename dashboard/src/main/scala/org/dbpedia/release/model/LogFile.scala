package org.dbpedia.release.model

import java.net.URL

import org.dbpedia.release.config.Config

object LogFile {

  def apply(baseUrl: URL, fileName: String): Option[LogFile] = {

    val logNameOption: Option[String] = fileName match {
      case mappings if mappings.startsWith("downloadMappings") =>
        Some(Config.extractionLogs.name.downloadMappings)
      case ontology if ontology.startsWith("downloadOntology") =>
        Some(Config.extractionLogs.name.downloadOntology)
      case dumps if dumps.startsWith("downloadWikidumps") =>
        Some(Config.extractionLogs.name.downloadWikidumps)
      case extract if extract.startsWith("extraction") =>
        Some(Config.extractionLogs.name.extraction)
      case postproc if postproc.startsWith("postProcessing") =>
        Some(Config.extractionLogs.name.postProcess)
      case unredirect if unredirect.startsWith("unredirected") =>
        Some(Config.extractionLogs.name.unredirected)
      case _ => None
    }

    val state = if (fileName.endsWith(".log.bz2") || fileName.endsWith("/")) 2 else 1

    logNameOption.map { logName =>
      LogFile(new URL(baseUrl, fileName).toString, logName, state,
        Config.extractionLogs.descriptionsBylogName.getOrElse(logName, "TODO"))
    }
  }
}

  case class LogFile(url: String, logName: String, state: Int, description: String) {
    lazy val stateString: String = state match {
      case 0 => "WAIT"
      case 1 => "RUN"
      case 2 => "DONE"
      case _ => "UNKNOWN"
    }
  }
