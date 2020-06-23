package org.dbpedia.release

case class CompletenessResponse
(
  artifactIri: String,
  versionStr: String,
  expectedFiles: String,
  actualFiles: String,
)
