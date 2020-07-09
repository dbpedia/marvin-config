package org.dbpedia.release

import java.io.{BufferedInputStream, FileInputStream}
import java.util.Properties

import scala.collection.mutable
import scala.jdk.CollectionConverters._

object Main extends App {

  /**
   * for f in $(find . -regex '.*2020.04.01.*\.ttl\.bz2')
   * do
   * echo $f | cut -d '/' -f4 | sed 's|\.ttl\.bz2||g' | sed 's|_lang=[a-z]*||g' | sed 's|_commons||g'
   * done
   */
  val databusCVNames = List(
    "anchor-text",
    "article-templates",
    "article-templates_nested",
    "categories_articles",
    "categories_labels",
    "categories_skos",
    "citations_data",
    "citations_links",
    "commons-sameas-links",
    "disambiguations",
    "external-links",
    "geo-coordinates",
    "homepages",
    "infobox-properties",
    "infobox-property-definitions",
    "interlanguage-links",
    "labels",
    "page_ids",
    "page_length",
    "persondata",
    "redirects",
    "redirects_transitive",
    "revisions_ids",
    "revisions_uris",
    "topical-concepts",
    "wikilinks",
    "wikipedia-links"
  )

  def finalLang(lang: String): String = {
    lang match {
      case "bat-smg" => "batsmg"
      case "zh-yue" => "yue"
      case "zh-min-nan" => "nan"
      case _ => lang
    }
  }


  val artifactsByExtractor = Map(
    ".AnchorTextExtractor" -> List("anchor-text"),
    ".ExternalLinksExtractor" -> List("external-links"),
    ".LabelExtractor" -> List("labels"),
    ".CitationExtractor" -> List("citations_data", "citations_links"),
    ".DisambiguationExtractor" -> List("disambiguations"),
    ".ArticleTemplatesExtractor" -> List("article-templates", "article-templates_nested"),
    ".HomepageExtractor" -> List("homepages"),
    ".RedirectExtractor" -> List("redirects", "redirects_transitive"), // redirects_transitive are due post-processing
    ".InterLanguageLinksExtractor" -> List("interlanguage-links"),
    ".WikiPageLengthExtractor" -> List("page_length"),
    ".PageLinksExtractor" -> List("wikilinks"),
    ".PageIdExtractor" -> List("page_ids"),
    ".PersondataExtractor" -> List("persondata"),
    ".TopicalConceptsExtractor" -> List("topical-concepts"),
    ".SkosCategoriesExtractor" -> List("categories_skos"),
    ".CategoryLabelExtractor" -> List("categories_labels"),
    ".InfoboxExtractor" -> List("infobox-properties", "infobox-property-definitions"),
    ".ArticleCategoriesExtractor" -> List("categories_articles"),
    ".CommonsResourceExtractor" -> List("commons-sameas-links"),
    ".GeoExtractor" -> List("geo-coordinates"),
    ".ProvenanceExtractor" -> List("revisions_uris"),
    ".RevisionIdExtractor" -> List("revisions_ids"),
    ".ArticlePageExtractor" -> List("wikipedia-links"),

    // Unknown
    ".WikiPageOutDegreeExtractor" -> List(),
    ".GalleryExtractor" -> List(),
    ".ContributorExtractor" -> List(),
    ".TemplateParameterExtractor" -> List(),
    ".ImageAnnotationExtractor" -> List(),
    ".CommonsKMLExtractor" -> List(),
    ".fr.PopulationExtractor" -> List(),
    ".FileTypeExtractor" -> List(),
    ".PndExtractor" -> List(),
    ".DBpediaResourceExtractor" -> List()
  )

  val properties = new Properties()

  val extractorMap = new mutable.HashMap[String, Set[String]]()

  properties.load(new BufferedInputStream(new FileInputStream("/home/marvin/src/git.informatik.uni-leipzig.de/dbpedia-assoc/marvin-config/extractionConfiguration/extraction.generic.properties")))

  // TODO en.properties (impl multiple configs loadable/merge)

  val defaultExtractors = properties.getProperty("extractors").split(',').map(_.trim).filter(_.nonEmpty).flatMap(e => artifactsByExtractor.getOrElse(e, List(e))).toSet

  (properties.getProperty("languages").split(',') ++ Array("en")).foreach(lang => {
    extractorMap(finalLang(lang)) = defaultExtractors
  })

  val LANG = "extractors\\.(.*)".r

  properties.asScala.foreach({
    case (LANG(lang), v) =>
      extractorMap(finalLang(lang)) = v.split(',').map(_.trim).filter(_.nonEmpty).flatMap(e => artifactsByExtractor.getOrElse(e, List(e))).toSet ++ defaultExtractors
    case _ => None
  })

  // TODO consider downloads.properties for this
  extractorMap.remove("ced")
  extractorMap.remove("mt")
  extractorMap.remove("commons")

  //  /* find unused but configured extractos */
  //  extractorMap.values.foldRight(Set[String]())( (a,b) => {
  //    a.filter(_.startsWith(".")) ++ b
  //  }).foreach(println)
  //

  extractorMap.values.flatMap(_.toList).groupBy((word: String) => word).map(x =>
    x._1 -> x._2.size
  ).foreach(println)

  hr

  val pagesLangs = Set(
    "vi",
    "lt",
    "zh",
    "ca",
    "am",
    "sco",
    "nn",
    "scn",
    "ku",
    "os",
    "war",
    "war",
    "ms",
    "mai",
    "no",
    "ku",
    "tr",
    "ru",
    "pms",
    "ky",
    "an",
    "eml",
    "ga",
    "nap",
    "kn",
    "id",
    "pl",
    "sah",
    "ga",
    "simple",
    "cv",
    "sd",
    "vec",
    "yue",
    "bn",
    "pnb",
    "bug",
    "ne",
    "pms",
    "hr",
    "ia",
    "tg",
    "als",
    "no",
    "da",
    "de",
    "azb",
    "ms",
    "qu",
    "he",
    "pnb",
    "yo",
    "li",
    "oc",
    "ja",
    "new",
    "lmo",
    "ceb",
    "my",
    "sd",
    "ur",
    "nds",
    "batsmg",
    "min",
    "wa",
    "hu",
    "ia",
    "lb",
    "wuu",
    "et",
    "arz",
    "ceb",
    "si",
    "an",
    "sah",
    "te",
    "ka",
    "eml",
    "da",
    "sr",
    "yi",
    "ja",
    "cy",
    "ko",
    "azb",
    "bs",
    "kk",
    "en",
    "ml",
    "fo",
    "simple",
    "sh",
    "ko",
    "en",
    "es",
    "tl",
    "sr",
    "sw",
    "be",
    "az",
    "gu",
    "ilo",
    "pt",
    "sk",
    "new",
    "eu",
    "tt",
    "af",
    "oc",
    "ht",
    "mzn",
    "ce",
    "th",
    "fa",
    "ta",
    "cs",
    "is",
    "el",
    "fy",
    "ar",
    "sl",
    "am",
    "sh",
    "el",
    "fo",
    "yo",
    "gl",
    "fi",
    "mrj",
    "wa",
    "lv",
    "ml",
    "os",
    "lmo",
    "cdo",
    "io",
    "te",
    "fr",
    "mn",
    "si",
    "la",
    "nl",
    "cy",
    "vi",
    "et",
    "arz",
    "nan",
    "vec",
    "hsb",
    "sq",
    "br",
    "cv",
    "lb",
    "mg",
    "mk",
    "gu",
    "mai",
    "br",
    "gd",
    "mzn",
    "sa",
    "ast",
    "ta",
    "vo",
    "bg",
    "or",
    "jv",
    "mr",
    "be",
    "sa",
    "wuu",
    "hi",
    "he",
    "uk",
    "ro",
    "pa",
    "nn",
    "qu",
    "su",
    "gd",
    "bn",
    "uz",
    "nds",
    "kk",
    "mhr",
    "ka",
    "xmf",
    "nap",
    "it",
    "jv",
    "gl",
    "is",
    "tl",
    "fa",
    "ce",
    "ht",
    "it",
    "eu",
    "ar",
    "az",
    "hu",
    "de",
    "ba",
    "bar",
    "uk",
    "fi",
    "pl",
    "sw",
    "mn",
    "es",
    "tt",
    "bug",
    "bs",
    "eo",
    "scn",
    "my",
    "yi",
    "ckb",
    "sq",
    "mg",
    "af",
    "mrj",
    "ilo",
    "su",
    "fr",
    "io",
    "hy",
    "ru",
    "als",
    "ro",
    "th",
    "sk",
    "ky",
    "fy",
    "min",
    "eo",
    "sl",
    "li",
    "hr",
    "tg",
    "pa",
    "hi",
    "tr",
    "sv",
    "hsb",
    "cdo",
    "mr",
    "or",
    "bar",
    "zh",
    "bg",
    "mhr",
    "ba",
    "vo",
    "lt",
    "yue",
    "ckb",
    "ast",
    "kn",
    "mk",
    "la",
    "bpy",
    "id",
    "hy",
    "sco",
    "ur",
    "nan",
    "pt",
    "uz",
    "bpy",
    "xmf",
    "nl",
    "cs",
    "lv",
    "ne",
    "batsmg",
    "sv",
    "ca"
  )

  hr

  pagesLangs.toList.sortWith(_ < _).foreach(str => print("\""+str+"\", "))

  /* check if something is missing */

  //  val pageIdsConfig = extractorMap.filter(_._2.contains("page_ids")).keys.toSet
  //
  //  pageIdsConfig.filterNot(pagesLangs).foreach(println)
  //
  //  hr
  //
  //  pagesLangs.filterNot(pageIdsConfig).foreach(println)

  private def hr: Unit = {
    println("--------------------------------------------------------------------------------------")
  }

  configuredButNotExtracted()

  private def configuredButNotExtracted(): Unit = {
    val c = ("af,als,am,an,ar,arz,ast,azb,az,ba,bar,bat-smg,be,bg,bn,bpy,br,bs,bug,ca,cdo,ceb,ce,ckb,cs,cv,cy,da,de,el," +
      "eml,eo,es,et,eu,fa,fi,fo,fr,fy,ga,gd,gl,gu,he,hi,hr,hsb,ht,hu,hy,ia,id,ilo,io,is,it,ja,jv,ka,kk,kn,ko,ku,ky,la,lb," +
      "li,lmo,lt,lv,mai,mg,mhr,min,mk,ml,mn,mrj,mr,ms,my,mzn,nap,nds,ne,new,nl,nn,no,oc,or,os,pa,pl,pms,pnb,pt,qu,ro,ru," +
      "sah,sa,scn,sco,sd,sh,si,simple,sk,sl,sq,sr,su,sv,sw,ta,te,tg,th,tl,tr,tt,uk,ur,uz,vec,vi,vo,wa,war,wuu,xmf,yi,yo," +
      "zh,zh-min-nan,zh-yue,commons,en")
      .split(",").toSet

    println
    c.toList.sortWith(_ < _).foreach(s => print("\""+s+"\", "))
//    val d = extractorMap.keys.toSet
//
//    d.filterNot(c).foreach(println)
  }

}
