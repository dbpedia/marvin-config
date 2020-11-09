//const api = "http://release-dashboard.dbpedia.org/api/"
const api = "http://localhost:8080/api/"

/* anchor scroll offset */
window.addEventListener("hashchange", function () {
  window.scrollTo(window.scrollX, window.scrollY - 80);
});

if (window.location.hash) {
  window.scrollTo(window.scrollX, window.scrollY - 80);
}

/* versions */

function latestDate() {
  const d = new Date();
  const ye = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(d)
  const mo = new Intl.DateTimeFormat('en', { month: '2-digit' }).format(d)
  return `${ye}.${mo}.01`;
};

const urlParams = new URLSearchParams(window.location.search)
var version = urlParams.get('version')
version = version ? version : latestDate()
var wikiversion = version.replace(/\./g,'')
// TODO change span to direct class change
document.getElementById("version-text").innerHTML = `<span class="text-info">${version} - Release</span>`

$.getJSON(api + "release/versions", function (data) {
  var versions = []
  data.forEach(element => {
    txtColo = element.state == 0 ? "text-danger" : "text-info"
    if(element.version == version && element.state == 0) document.getElementById("version-text").innerHTML = `<span class="text-danger">${version} - Release</span>`
    versions.push({
      'version':
        '<a class="' + txtColo + '" href="?version=' + element.version + '#version">' + element.version + '</a> ' +
        '<a class="text-dark" href="?version=' + element.version + '#mappings">m</a>|' +
        '<a class="text-dark" href="?version=' + element.version + '#generic">g</a>|' +
        '<a class="text-dark" href="?version=' + element.version + '#wikidata">w</a>'
    })
  });
  $('#version-table').bootstrapTable({ 'data': versions })
});

/* disclaimer */

var coll = document.getElementsByClassName("collapsible");
var i;

for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.display === "block") {
      content.style.display = "none";
    } else {
      content.style.display = "block";
    }
  });
}

/* dump-downloads */

function drawDumpChart(group, fin, wait, miss) {
  google.charts.load('current', { 'packages': ['corechart'] });
  google.charts.setOnLoadCallback( function() {
    var data = google.visualization.arrayToDataTable([
      ['State', 'Number'],
      ['Finished', fin],
      ['Waiting', wait],
      ['Mssing', miss]
    ]);

    var options = {
      colors: ['#28a745', '#17a2b8', '#dc3545'],
      pieHole: 0.5,
      pieSliceText: 'value',
    };

    var chart = new google.visualization.PieChart(document.getElementById(`${group}-downloads-chart`));
    chart.draw(data, options);
  });
}

function getInputState(group) {

  $.getJSON(api + `release/downloads/${group}/${version}`, function (data) {

    let done = data['done'] || []
    let wait = data['waiting'] || []
    let fail = data['failed'] || []


    if( wait.length == 0 )
      $(`#${group}-missing-input`).html('None')
    else
      $(`#${group}-missing-input`).html(wait.map( e => `<a href="http://dumps.wikimedia.org/${e}wiki/${wikiversion}">${e}wiki</a>`).join(', '))


    if( fail.length == 0 )
      $(`#${group}-failed-input`).html('None')
    else
      $(`#${group}-failed-input`).html(fail.map( e => `<a href="http://dumps.wikimedia.org/${e}wiki/${wikiversion}">${e}wiki</a>`).join(', '))

    drawDumpChart(group, done.length, wait.length, fail.length)
  })
}

$(function () {
  getInputState('mappings')
  getInputState('generic')
  getInputState('wikidata')
});

/* log-files */

var stepByLog = {
   "downloadMappings.log" : "mappings downlaod",
   "downloadOntology.log" : "ontology downlaod",
   "downloadWikidumps.log" : "wikidump download",
   "extraction.log" : "knowledge extraction",
   "postProcess.log" : "post processing",
   "unRedirected/" : "copy un-redirected files"
}

function getLogs(group) {
  // n/a - not loaded, 
  // unzipped - in progress, 
  // zipped - done (but success unclear)

  var logTable = $(`#${group}-logs-table`)

  $.getJSON(api + `release/logs/${group}/${version}`, function (data) {

    var processLogs = []
    var doneSteps = 0
    var isRunning = false
    var step = 6
    var stepHtml = ""

    data.forEach(element => {
      step += -1
      var state = element.state
      if (state == 0) {
        state = '<strong class="text-warning">WAIT</strong>'
      } else if (state == 1) {
        stepHtml = stepByLog[element.logName] || stepHtml
	    doneSteps += 1
	    isRunning = true
        state = '<strong class="text-success">RUN</strong>'
      } else {
        doneSteps += 1
        state = '<strong class="text-info">DONE</strong>'
      }

      var url = element.url
      var file = element.logName
      var description = element.description
      processLogs.push({ 'step': step+1, 'state': element.state, 'stateHtml': state, 'description': description, 'filename': `<a href="${url}">${file}</a>` })
    })

    if ( isRunning ) doneSteps -= 1;

    setProgress(group, doneSteps, 6)

    if (stepHtml != "" && isRunning ) $(`#${group}-progress-step`).append(`@ ${stepHtml}`)
    else if ( (step-6) == 0 && latestDate() == version ) $(`#${group}-progress-step`).append(` not started yet`)


    processLogs.sort( function(a, b) {return a.step - b.step} )
    
    /** This sorts by state and step */
    // processLogs.sort( function(a,b) {
    //   if (a.state == 1) return -1
    //   else if ( b.state == 1) return 1
    //   else return b.state-a.state
    //   })

    logTable.bootstrapTable({ 'data': processLogs });
  });
}

function setProgress(group, actual, max) {

  let progBar = $(`#${group}-progress`)
  let percent = actual * 100 / max
  progBar.html(`(${actual}/${max}) Steps`)
  progBar.css('width', percent + '%')
  if (percent >= 100.0) {
    progBar.addClass('bg-success')
  } else if (actual == 0.0) {
    progBar.css('width', '100%')
    progBar.addClass('bg-secondary')
  } else {
    progBar .addClass('bg-warning')
  }
}

$(function () {
  getLogs('mappings')
  getLogs('generic')
  getLogs('wikidata')
})

http://localhost:8080/api/release/logs/wikidata/2020.05.01

/* completness */

//* group link *//

/** Not needed atm */
// document.getElementById("mappings-group-link").href=`https://databus.dbpedia.org/marvin/mappings/${version}`
// document.getElementById("generic-group-link").href=`https://databus.dbpedia.org/marvin/generic/${version}`
// document.getElementById("wikidata-group-link").href=`https://databus.dbpedia.org/marvin/wikidata/${version}`

//* artifact check *//

var mappingsCompQuery = `
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX dcat:   <http://www.w3.org/ns/dcat#>
SELECT ?expected_files ?actual_files ?delta ?artifact {
  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
      VALUES (?artifact ?expected_files) {
        ( <https://databus.dbpedia.org/marvin/mappings/geo-coordinates-mappingbased> 29 )
        ( <https://databus.dbpedia.org/marvin/mappings/instance-types> 80 )
        ( <https://databus.dbpedia.org/marvin/mappings/mappingbased-literals> 40 )
        ( <https://databus.dbpedia.org/marvin/mappings/mappingbased-objects> 120 )
        ( <https://databus.dbpedia.org/marvin/mappings/mappingbased-objects-uncleaned> 40 )
        ( <https://databus.dbpedia.org/marvin/mappings/specific-mappingbased-properties> 40 )
      }
      ?dataset dataid:artifact ?artifact .
      ?dataset dct:hasVersion ?versionString .
      ?dataset dcat:distribution ?distribution .
      FILTER(str(?versionString) = '$version')
    } GROUP BY ?artifact ?expected_files ?actual_files }
}`.replace('$version',version)

var genericCompQuery = `
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX dcat:   <http://www.w3.org/ns/dcat#>
SELECT ?expected_files ?actual_files ?delta ?artifact {
    {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
      VALUES (?artifact ?expected_files) {
        ( <https://databus.dbpedia.org/marvin/generic/anchor-text> 1 )
        ( <https://databus.dbpedia.org/marvin/generic/article-templates> 278 )
        ( <https://databus.dbpedia.org/marvin/generic/categories> 417 )
        ( <https://databus.dbpedia.org/marvin/generic/citations> 2 )
        ( <https://databus.dbpedia.org/marvin/generic/commons-sameas-links> 7 )
        ( <https://databus.dbpedia.org/marvin/generic/disambiguations> 15 )
        ( <https://databus.dbpedia.org/marvin/generic/external-links> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/geo-coordinates> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/homepages> 13 )
        ( <https://databus.dbpedia.org/marvin/generic/infobox-properties> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/infobox-property-definitions> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/interlanguage-links> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/labels> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/page> 278 )
        ( <https://databus.dbpedia.org/marvin/generic/persondata> 4 )
        ( <https://databus.dbpedia.org/marvin/generic/redirects> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/revisions> 278 )
        ( <https://databus.dbpedia.org/marvin/generic/topical-concepts>11 )
        ( <https://databus.dbpedia.org/marvin/generic/wikilinks> 139 )
        ( <https://databus.dbpedia.org/marvin/generic/wikipedia-links> 139 )
      }
      ?dataset dataid:artifact ?artifact .
      ?dataset dct:hasVersion ?versionString .
      ?dataset dcat:distribution ?distribution .
      FILTER(str(?versionString) = '$version')
    } GROUP BY ?artifact ?expected_files ?actual_files }
}`.replace('$version',version)

var wikidataCompQuery = `
PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX dcat:   <http://www.w3.org/ns/dcat#>
SELECT ?expected_files ?actual_files ?delta ?artifact {
  {SELECT ?expected_files  (COUNT(DISTINCT ?distribution) as ?actual_files) ((?actual_files-?expected_files)AS ?delta) ?artifact {
      VALUES (?artifact ?expected_files) {
        ( <https://databus.dbpedia.org/marvin/wikidata/alias> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/debug> 3 )
        ( <https://databus.dbpedia.org/marvin/wikidata/description> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/geo-coordinates> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/images> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/instance-types> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/labels> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-literals> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-objects-uncleaned> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/mappingbased-properties-reified> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/ontology-subclassof> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/page> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/properties> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/redirects> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/references> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/revision> 2 )
        ( <https://databus.dbpedia.org/marvin/wikidata/sameas-all-wikis> 1 )
        ( <https://databus.dbpedia.org/marvin/wikidata/sameas-external> 1 )
      }
      ?dataset dataid:artifact ?artifact .
      ?dataset dct:hasVersion ?versionString .
      ?dataset dcat:distribution ?distribution .
      FILTER(str(?versionString) = '$version')
    } GROUP BY ?artifact ?expected_files ?actual_files }
}`.replace('$version',version)

function linkQuery(publisherName, group, query) {
  var encodedQuery = encodeURIComponent(query)
  if(publisherName == 'marvin') {
    var link = `https://databus.dbpedia.org/yasgui/#query=${encodedQuery}`
    $(`#${publisherName}-${group}-comp-query`).attr("href", link);
  }
  else {
    var link = `https://databus.dbpedia.org/yasgui/#query=${encodedQuery}`
    $(`#${publisherName}-${group}-comp-query`).attr("href", link);
  }

}
linkQuery('marvin','mappings',mappingsCompQuery)
linkQuery('marvin','generic',genericCompQuery)
linkQuery('marvin','wikidata',wikidataCompQuery)
linkQuery('dbpedia','mappings',mappingsCompQuery)
linkQuery('dbpedia','generic',genericCompQuery)
linkQuery('dbpedia','wikidata',wikidataCompQuery)

function checkCompleteness(publisherName, group, expectedArtifacts) {

  var mappingsCompletenessTable = $(`#${publisherName}-${group}-completeness-table`)

  $.getJSON(api + `release/completeness/${publisherName}/${group}/${version}`, function (data) {
    var expectedFilesTotal = 0
    var actualFilesTotal = 0
    var actualArtifacts = 0
    var releaseCompleteness = []
    data.forEach(element => {
      actualArtifacts += 1
      var exp = element['expected']
      var act = element['actual']

      expectedFilesTotal += exp
      actualFilesTotal += act

      var state = act < exp ? '<strong class="text-warning">WARN</strong>' : '<strong class="text-info">OK</strong>'
      var missing = act < exp ? exp - act : 0

      releaseCompleteness.push({
        'artifact': `<a href="https://databus.dbpedia.org/marvin/${group}/${element['artifact']}/${version}">${element['artifact']}</a>`,
        'state': state,
        'missing': missing,
      });
    });
    releaseCompleteness.sort((a, b) => b.missing - a.missing)
    mappingsCompletenessTable.bootstrapTable({ 'data': releaseCompleteness })

    let progBarArt = $(`#${publisherName}-${group}-completeness-artifacts`)
    setProgressBar(progBarArt, actualArtifacts, expectedArtifacts)
    // progBarArt.html(`${actualArtifacts}/${expectedArtifacts} `)
    // let progArt = actualArtifacts * 100 / expectedArtifacts
    // progBarArt.css('width', progArt + '%')
    // if (progArt >= 100.0) progBarArt.addClass('bg-info')
    // else if (progArt < 50) progBarArt.addClass('bg-danger')
    // else progBarArt.addClass('bg-warning')

    let progBarFil = $(`#${publisherName}-${group}-completeness-files`)
    setProgressBar(progBarFil, actualFilesTotal, expectedFilesTotal)
    // progBarFil.html(`${actualFilesTotal}/${expectedFilesTotal}`)
    // let progFil = actualFilesTotal * 100 / expectedFilesTotal
    // progBarFil.css('width', progFil + '%')
    // if (progFil >= 100) progBarFil.addClass('bg-info')
    // else if (progFil < 50) progBarFil.addClass('bg-danger')
    // else progBarFil.addClass('bg-warning')
  });
}

function setProgressBar(bar, actual, max) {
  bar.html(`(${actual}/${max})`)
  var percentage = actual * 100 / max
  bar.css('width', percentage + '%')
  if (percentage >= 100.0)
    bar.addClass('bg-info')
  else if (actual == 0.0) {
    bar.css('width', '100%')
    bar.addClass('bg-danger')
  } else
    bar.addClass('bg-warning')
}

$(function () {
  checkCompleteness('marvin','mappings', 6)
  checkCompleteness('marvin','generic', 20)
  checkCompleteness('marvin','wikidata', 16)
  checkCompleteness('dbpedia','mappings', 6)
  checkCompleteness('dbpedia','generic', 20)
  checkCompleteness('dbpedia','wikidata', 16)
})

