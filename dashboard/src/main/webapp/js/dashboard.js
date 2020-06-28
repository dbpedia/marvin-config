var [publisher, group, version] = window.location.pathname.split("/").slice(1,4)
var showTotalStats = publisher ? false : true

document.getElementById("groupVersion").innerHTML = showTotalStats ? "Total Statistics" : group+"/"+version

