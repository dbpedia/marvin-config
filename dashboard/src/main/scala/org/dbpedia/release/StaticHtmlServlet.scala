package org.dbpedia.release

import java.io.File

import org.scalatra.{InternalServerError, NotFound, ScalatraServlet}

class StaticHtmlServlet extends ScalatraServlet {

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
