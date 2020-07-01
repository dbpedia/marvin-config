const api = "http://localhost:8080/api/"

/* anchor scroll offset */
window.addEventListener("hashchange", function () {
    window.scrollTo(window.scrollX, window.scrollY - 80);
});

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
document.getElementById("version-text").innerHTML = version + " - Release"

$.getJSON(api + "release/versions", function (data) {
  var versions = []
  data.forEach(element => {
    txtColo = element.state == 0 ? "text-danger" : "text-info"
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

/* total */

/* overall */

/* mappings-dumps */

google.charts.load('current', { 'packages': ['corechart'] });
google.charts.setOnLoadCallback(drawChart);

function drawChart() {

  var data = google.visualization.arrayToDataTable([
    ['State', 'Number'],
    ['Finished', 32],
    ['Waiting', 5],
    ['Mssing', 3]
  ]);

  var options = {
    colors: ['#28a745', '#17a2b8', '#dc3545'],
    pieHole: 0.5,
    pieSliceText: 'value',
  };

  var chart = new google.visualization.PieChart(document.getElementById('mappings-downloads'));
  chart.draw(data, options);
}

/* mappings-logs */

// n/a - not loaded, 
// unzipped - in progress, 
// zipped - done (but success unclear)
var mappingsLogsTable = $('#mappings-logs')

$(function () {
  var data = [
    {
      'filename': '<a href="#">preprocess.log</a>',
      'description': 'preprocessing (todo explain)',
      'state': '<span class="text-warning">RUN</span>'
    },
    {
      'filename': '<a href="#">extraction.mappings.log</a>',
      'description': 'process of DIEF',
      'state': '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">dump.log</a>',
      'description': 'download of latest dumps',
      'state': '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">ontology.log</a>',
      'description': 'download of latest ontology',
      'state': '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">mappings.log</a>',
      'description': 'download of latest mappings',
      'state': '<span class="text-success">DONE</span>'
    },
    {
      'filename': 'deploy.log',
      'description': 'deploy on databus',
      'state': '<span class="text-danger">WAIT</span>'
    }
  ]
  mappingsLogsTable.bootstrapTable({ data: data })
})

/* mappings-completness */

var mappingsCompletenessTable = $('#mappings-completeness')

$(function () {
  $.getJSON(api + `release/completeness/mappings/${version}`, function (data) {


  });
});

/* generic */

/* wikidata-completness */


function checkCompleteness(group, expectedArtifacts) {

  var mappingsCompletenessTable = $(`#${group}-completeness-table`)

  $.getJSON(api + `release/completeness/${group}/${version}`, function (data) {
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

      var stateVal = act < exp ? 0 : 1
      var state = act < exp ? '<strong class="text-warning">WARN</strong>' : '<strong class="text-info">OK</strong>'
      var missing = act < exp ? exp - act : 0

      releaseCompleteness.push({
        'artifact': element['artifact'],
        'state': state,
        'missing': missing,
        'stateVal': stateVal
      });
    });
    releaseCompleteness.sort((a, b) => a.stateVal - b.stateVal)
    mappingsCompletenessTable.bootstrapTable({ 'data': releaseCompleteness })

    let progBarArt = $(`#${group}-completeness-artifacts`)
    progBarArt.html(`${actualArtifacts}/${expectedArtifacts} `)
    let progArt = actualArtifacts * 100 / expectedArtifacts
    progBarArt.css('width', progArt + '%')
    if (progArt >= 100.0 ) progBarArt.addClass('bg-info')
    else if (progArt < 50) progBarArt.addClass('bg-danger')
    else progBarArt.addClass('bg-warning')

    let progBarFil = $(`#${group}-completeness-files`)
    progBarFil.html(`${actualFilesTotal}/${expectedFilesTotal}`)
    let progFil = actualFilesTotal * 100 / expectedFilesTotal
    progBarFil.css('width', progFil + '%')
    if (progFil >= 100) progBarFil.addClass('bg-info')
    else if (progFil < 50) progBarFil.addClass('bg-danger')
    else progBarFil.addClass('bg-warning')
  });
}

$(function() {
  checkCompleteness('mappings',6)
  checkCompleteness('generic',20)
  checkCompleteness('wikidata',16)


  // checkCompleteness('mapp')
})


/** FUNCTIONS **/

/* get latest version from api or from date*/
// function getLatestVersion() {
//   // TODO
//   return "2020.05.01"
// }
