const api = "/api/"

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

function getLogs(group) {
  // n/a - not loaded, 
  // unzipped - in progress, 
  // zipped - done (but success unclear)

  var logTable = $(`#${group}-logs-table`)

  $.getJSON(api + `release/logs/${group}/${version}`, function (data) {

    var processLogs = []
    var doneSteps = 0
    var isRunning = false

    data.forEach(element => {

      var state = element.state
      if (state == 0) {
        state = '<strong class="text-warning">WARN</strong>'
      } else if (state == 1) {
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
      processLogs.push({ 'state': state, 'description': description, 'filename': `<a href="${url}">${file}</a>` })
    })

    if ( isRunning ) doneSteps -= 1;

    setProgress(group, doneSteps, 6)
    logTable.bootstrapTable({ 'data': processLogs })
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

      var state = act < exp ? '<strong class="text-warning">WARN</strong>' : '<strong class="text-info">OK</strong>'
      var missing = act < exp ? exp - act : 0

      releaseCompleteness.push({
        'artifact': element['artifact'],
        'state': state,
        'missing': missing,
      });
    });
    releaseCompleteness.sort((a, b) => b.missing - a.missing)
    mappingsCompletenessTable.bootstrapTable({ 'data': releaseCompleteness })

    let progBarArt = $(`#${group}-completeness-artifacts`)
    setProgressBar(progBarArt, actualArtifacts, expectedArtifacts)
    // progBarArt.html(`${actualArtifacts}/${expectedArtifacts} `)
    // let progArt = actualArtifacts * 100 / expectedArtifacts
    // progBarArt.css('width', progArt + '%')
    // if (progArt >= 100.0) progBarArt.addClass('bg-info')
    // else if (progArt < 50) progBarArt.addClass('bg-danger')
    // else progBarArt.addClass('bg-warning')

    let progBarFil = $(`#${group}-completeness-files`)
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
  checkCompleteness('mappings', 6)
  checkCompleteness('generic', 20)
  checkCompleteness('wikidata', 16)
})
