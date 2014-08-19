var width = 1000, height = 600,
    barHeight = 15,
    indent = 200;

var svg = d3.select("body")
  .append("svg")
    .attr("id", "graph")
    .attr("width", width)
    .attr("height", height);
            
var twitterData = {},
    maxTweets = 0,
    xScale = d3.scale.linear().domain([0, maxTweets]).range([0, width - indent]);

poll();
var polling = setInterval(poll, 5000);

function poll() {
    $.ajax({
        dataType: "json",
        url: "/get/data.json",
        success: updateTwitterData,
        error: function() { clearInterval(polling); }
    });
}

function updateTwitterData(newData) {
    for (var k in newData) {
        if (!twitterData[k]) {
            twitterData[k] = newData[k];
        } else {
            twitterData[k] += newData[k];
        }
        
        if (twitterData[k] > maxTweets) {
            maxTweets = twitterData[k]
        }
    }
    updateChart();
}

function updateChart() {
    console.log("chart");

    xScale.domain([0, scaleUp(maxTweets)]);
    //xScale.domain([0, 1000]);
    
    var data = d3.entries(twitterData);
    data.sort(function(a, b) {
        return b.value - a.value;
    });
    
    console.log(data.length);
    
    var bars = svg.selectAll("rect")
        .data(data, function(d) { return d.key; });
    
    // Add new bars:
    bars.enter().append("rect")
        .attr("width", 0)
        .attr("height", barHeight)
        .attr("x", 200)
        .attr("y", data.length * (barHeight + 2))
        .attr("fill", "steelblue");
      
    //bars.append("text")
    //    .attr("x", function(d) { return xScale(d.value); })
    //    .attr("y", function(d, i) { return i * (barHeight + 2); })
    //    .attr("fill", "black")
    //    .text(function(d) { return d.key; });
        
    bars.transition().duration(1000)
        .attr("width", function(d) { return xScale(d.value) })
      .transition().duration(1000)
        .attr("y", function(d, i) { return i * (barHeight + 2); });
        
    bars.exit().remove();
    
    
    //////////////////////
    var labels = svg.selectAll("text")
        .data(data, function(d) { return d.key; });
        
    labels.enter().append("text")
        .attr("x", 195)
        .attr("y", data.length * (barHeight + 2))
        .attr("fill", "black")
        .attr("text-anchor", "end")
        .attr("dy", "1em")
        .text(function(d) { ""; });
        
    labels.transition().duration(1000)
        .attr("x", 195)
        .text(function(d) { return d.key + " | " + d.value; })
      .transition().duration(1000)
        .attr("y", function(d, i) { return i * (barHeight + 2); });
                
    $("svg").attr("height", data.length * (barHeight + 2))
}

function scaleUp(x) {
    var temp = x,
        power = 0;
    while (temp > 1) {
        power++;
        temp /= 10;
    }
    var scale = Math.pow(10, power);
   
    if (scale/2 > x) {
        scale /= 2;
        if (scale/2 > x) {
            scale /= 2
        }
    }
    return scale;
}