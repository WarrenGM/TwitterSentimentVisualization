var svg = d3.select("body")
            .append("svg")
            .attr("id", "graph")
            .attr("width", 200)
            .attr("height", 200);
            
var twitterData = {};

setInterval(poll, 5000);

function poll() {
    $.ajax({
        dataType: "json",
        url: "/get/data.json",
        success: updataTwitterData,
        error: function() {}
    });
}

function updataTwitterData(newData) {
    for (var k in newData) {
        if (!twitterData[k]) {
            twitterData[k] = newData[k];
        } else {
            twitterData[k] += newData[k];
        }
    }
    console.log(twitterData);
}