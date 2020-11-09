package org.dbpedia.release

import org.scalatra.test.scalatest._

class ReleaseDashboardServletTests extends ScalatraFunSuite {

  addServlet(classOf[DataApiServlet], "/*")

  test("GET / on ReleaseDashboardServlet should return status 200") {
    get("/") {
      status should equal (200)
    }
  }

  override def header = {}
}
