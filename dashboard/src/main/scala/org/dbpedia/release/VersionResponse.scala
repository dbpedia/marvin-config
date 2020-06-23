package org.dbpedia.release

case class VersionResponse
(
  group: String,
  marvin: List[String],
  dbpedia: List[String]
)
