val ScalatraVersion = "2.7.0"

organization := "org.dbpedia"

name := "Release Dashboard"

version := "1.0-SNAPSHOT"

scalaVersion := "2.13.1"

resolvers += Classpaths.typesafeReleases

libraryDependencies ++= Seq(
  "org.scalatra" %% "scalatra" % ScalatraVersion,
  "org.scalatra" %% "scalatra-scalatest" % ScalatraVersion % "test",
  "org.scalatra" %% "scalatra-json" % "2.7.0",
  "org.json4s" %% "json4s-jackson" % "3.6.9",
  "org.scalatra" %% "scalatra-swagger" % "2.3.0",
  "ch.qos.logback" % "logback-classic" % "1.2.3" % "runtime",
  "org.eclipse.jetty" % "jetty-webapp" % "9.4.28.v20200408" % "container",
  "javax.servlet" % "javax.servlet-api" % "3.1.0" % "provided",
)

// https://mvnrepository.com/artifact/org.apache.jena/jena-arq
libraryDependencies += "org.apache.jena" % "jena-arq" % "3.15.0"

enablePlugins(SbtTwirl)
enablePlugins(ScalatraPlugin)
