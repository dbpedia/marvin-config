package org.dbpedia.release.model

import java.net.URL

import org.dbpedia.release.config.Config

object LogFile {
  def apply(baseUrl: URL, fileName: String): Option[LogFile] = {

    // TODO if else looks better
    val logNameOption = fileName match {
      case mappings if mappings.startsWith("downloadMappings") => Some(Config.extractionLogs.name.downloadMappings)
      case ontology if ontology.startsWith("downloadOntology") => Some(Config.extractionLogs.name.downloadOntology)
      case dumps if dumps.startsWith("downloadWikidumps") => Some(Config.extractionLogs.name.downloadWikidumps)
      case extract if extract.startsWith("extraction") => Some(Config.extractionLogs.name.extraction)
      case postproc if postproc.startsWith("postProcessing") => Some(Config.extractionLogs.name.postProcess)
      case unredirect if unredirect.startsWith("unredirected") => Some(Config.extractionLogs.name.unredirected)
      case _ => None
    }

    val state = if (fileName.endsWith(".log.bz2") || fileName.endsWith("/")) "DONE"  else "RUN"

    logNameOption.map(logName => new LogFile(new URL(baseUrl, fileName).toString, logName, state))
  }
}

case class LogFile(url: String, logName: String, state: String)
