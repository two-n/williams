define ["d3"], (d3) ->
  (deps = [], callback) ->
    selectors = [
      ".rows"
      ".lines"
      ".x-axis"
      ".y-axis"
      ".label"
      "#vectorMap"
    ]

    waste = @selectAll(selectors)
    waste = waste.filter(":not(#{ dep })") for dep in deps
    duration = 600

    waste.filter("#vectorMap")
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter(".x-axis, .y-axis").transition().duration(duration)
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter(".label").transition().duration(duration)
      .attr
        "fill-opacity" : 0

    waste.filter(".rows").selectAll(".row")
      .transition().duration(duration)
      .attr "fill-opacity": 0
      .selectAll(".bar")
      .attr "width": 0

    waste.filter(".lines")  # TODO improve transition
      .transition().duration(duration)
      .selectAll(".line")
      .attr "stroke-opacity": 0


    waste.classed("exiting", true).call (exiting) ->
      if exiting.empty() then return callback()
      setTimeout ->
        exiting.remove()
        callback()
      , duration
