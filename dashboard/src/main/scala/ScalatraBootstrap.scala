import org.dbpedia.release._
import org.scalatra._
import javax.servlet.ServletContext


class ScalatraBootstrap extends LifeCycle {

  implicit val swagger = new DataApiSwagger

  override def init(context: ServletContext) {
    context.setInitParameter("org.scalatra.cors.allowCredentials","false")
    context.mount(new DataApiServlet, "/api/*", "data-api")
    context.mount(new StaticHtmlServlet, "/*", "static-html")
    context.mount(new ResourcesApp, "/api-docs")
  }
}
