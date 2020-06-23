package org.dbpedia.release

import org.scalatra.ScalatraServlet
import org.scalatra.json.JacksonJsonSupport
import org.scalatra.swagger.{ApiInfo, ContactInfo, JacksonSwaggerBase, LicenseInfo, NativeSwaggerBase, Swagger}


class ResourcesApp(implicit val swagger: Swagger) extends ScalatraServlet with JacksonSwaggerBase {

  get("/") {
    """    <!DOCTYPE html>
      |    <html>
      |    <head>
      |    <title>ReDoc</title>
      |    <!-- needed for adaptive design -->
      |    <meta charset="utf-8"/>
      |    <meta name="viewport" content="width=device-width, initial-scale=1">
      |    <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
      |    <!--
      |    ReDoc doesn't change outer page styles
      |    -->
      |    <style>
      |      body {
      |        margin: 0;
      |        padding: 0;
      |      }
      |    </style>
      |    </head>
      |    <body>
      |    <redoc spec-url='/api-docs/swagger.json'></redoc>
      |    <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"> </script>
      |    </body>
      |    </html>
      |""".stripMargin
  }
}

object FlowersApiInfo
  extends ApiInfo(
    "DBpedia Release Dashboard API",
    "Docs for the DBpedia Release Dashboard API",
    "http://dbpedia.org",
    ContactInfo("Marvin Hofer", "", "nomail@mail.no"),
    LicenseInfo("TODO", "http://todo.org/lisence")
  )

class DataApiSwagger extends Swagger(Swagger.SpecVersion, "1.0.0", FlowersApiInfo)
