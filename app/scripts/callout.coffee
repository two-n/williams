define ["d3"], (d3) ->

  callout = (coords) ->
    callout = d3.select(".callout")
    if callout.empty()
      callout = @.append("g").classed("callout", true)

    callout
      .attr
        transform: "translate(#{coords[0]},#{coords[1]})"

    box = callout.select("rect")
    if box.empty()
      box = callout.append("rect")
    box.attr
      width: 200
      height: 200
      fill: "red"