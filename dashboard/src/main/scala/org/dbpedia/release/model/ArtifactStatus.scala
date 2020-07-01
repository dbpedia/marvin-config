package org.dbpedia.release.model

case class ArtifactStatus(group: String, artifact: String, version: String, expected : Int, actual: Int)
