/* anchor scroll offset */
window.addEventListener("hashchange", function () {
    this.console.log("#")
    window.scrollTo(window.scrollX, window.scrollY - 80);
});

// var [publisher, group, version] = window.location.pathname.split("/").slice(1,4)

/** TOTAL **/
// TODO

/** RELASE **/

/* version */
const urlParams = new URLSearchParams(window.location.search)
var version = urlParams.get('version')
version = version ? version : getLatestVersion()
document.getElementById("version-text").innerHTML = "Release: " + (version ?  version : "2020.X.X") +" (todo fetch)"

/* overall */

/** mappings **/

/* mappings-download */

google.charts.load('current', {'packages':['corechart']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {

  var data = google.visualization.arrayToDataTable([
    ['State', 'Number'],
    ['Finished',     30],
    ['Waiting',      9],
    ['Mssing',      1]
  ]);

  var options = {
    colors:['#28a745','#17a2b8','#dc3545'],
    pieHole: 0.5,
    pieSliceText: 'value',
  };

  var chart = new google.visualization.PieChart(document.getElementById('mappings-downloads'));
  chart.draw(data, options);
}

/* mappings logs */

// n/a - not loaded, 
// unzipped - in progress, 
// zipped - done (but success unclear)
var $table = $('#mappings-logs')

$(function() {
  var data = [
    {
      'filename': '<a href="#">preprocess.log</a>',
      'description': 'preprocessing (todo explain)',
      'state' : '<span class="text-warning">RUN</span>'
    },
    {
      'filename': '<a href="#">extraction.mappings.log</a>',
      'description': 'process of DIEF',
      'state' : '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">dump.log</a>',
      'description': 'download of latest dumps',
      'state' : '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">ontology.log</a>',
      'description': 'download of latest ontology',
      'state' : '<span class="text-success">DONE</span>'
    },
    {
      'filename': '<a href="#">mappings.log</a>',
      'description': 'download of latest mappings',
      'state' : '<span class="text-success">DONE</span>'
    },
    {
      'filename': 'deploy.log',
      'description': 'deploy on databus',
      'state' : '<span class="text-danger">WAIT</span>'
    }
  ]
  $table.bootstrapTable({data: data})
})

/* mappings completness */



/* generic */

/* wikidata */

/** FUNCTIONS **/

/* get latest version from api or from date*/
function getLatestVersion() {
    // TODO
    return "2020.05.01" 
}
