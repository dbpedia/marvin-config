/* anchor scroll */
window.addEventListener("hashchange", function () {
    this.console.log("#")
    window.scrollTo(window.scrollX, window.scrollY + 100);
});


var [publisher, group, version] = window.location.pathname.split("/").slice(1,4)
var showTotalStats = publisher ? false : true

document.getElementById("groupVersion").innerHTML = showTotalStats ? "Total Statistics" : group+"/"+version

