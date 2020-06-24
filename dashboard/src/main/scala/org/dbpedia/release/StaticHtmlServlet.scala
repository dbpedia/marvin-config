package org.dbpedia.release

import java.io.File

import org.scalatra.{InternalServerError, NotFound, Ok, ScalatraServlet}
import org.slf4j.LoggerFactory

class StaticHtmlServlet extends ScalatraServlet {

  private val log = LoggerFactory.getLogger(classOf[StaticHtmlServlet])

  /**
   * serve static files
   *
   * @param path relative path to 'http(s)://host:port/' and 'src/main/webapp/'
   * @return static file content
   */
  def html(path: String): File = {
    contentType = "text/html"
    new File(getServletContext.getResource(path).getFile)
  }

  val versionPattern = """\d\d\d\d\.\d\d.\d\d""".r

  get("/:p/:g/:v") {
    params("g") match {
      case "mappings" | "generic" | "wikidata" =>
        if (versionPattern matches params("v"))
          new File(getServletContext.getResource("/index.html").getFile)
        else NotFound(html("/notFound.html"))
      case _ => NotFound(html("/notFound.html"))
    }
  }

  /**
   * default page for HttpStatus 404 Not Found
   */
  notFound {
    serveStaticResource() getOrElse NotFound(html("/notFound.html"))
  }

  /**
   * default page for HttpStatus 500 Internal Server
   */
  error {
    case e: Exception => InternalServerError(html("/error.html"))
  }
}
