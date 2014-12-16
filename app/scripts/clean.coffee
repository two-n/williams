define ["d3"], (d3) ->
  (deps = [], callback) ->
    selectors = [
      ".rows"
      ".lines"
      ".pies"
      ".benchmarks"
      ".x-axis"
      ".y-axis"
      ".label"
      "#vectorMap"
      ".unscaledRegionOverlay"
      ".calloutSurface"
      ".timeAxis"
      ".quote"
      ".view-report-btn"
    ]

    waste = @selectAll(selectors)
    waste = waste.filter(":not(#{ dep })") for dep in deps
    duration = 600

    waste.filter("#vectorMap")
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter(".timeAxis")
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter(".calloutSurface")
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter(".x-axis, .y-axis").transition().duration(duration)
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0
      .selectAll(".halfway-line, .tick").attr "opacity": 0

    waste.filter(".label").transition().duration(duration)
      .attr
        "fill-opacity" : 0

    waste.filter(".rows").selectAll(".row")
      .transition().duration(duration)
      .attr "fill-opacity": 0
      .selectAll(".bar")
      .attr "width": 0

    waste.filter(".lines").selectAll(".line")
      .each ->
        length = @getTotalLength()
        d3.select(@)
          .attr
            "stroke-dasharray": "0px #{length}px #{length}px 0px"
            "stroke-dashoffset": "#{length}px"
      .transition("dasharray").duration(duration)
      .attr
        "stroke-dashoffset": 0
        "stroke-opacity": 0

    waste.filter(".pies").selectAll(".pie")
      .attr "opacity", 1
      .transition().duration(duration)
      .attr "opacity", 0

    waste.filter(".benchmarks").selectAll(".benchmark")
      .attr "opacity", 1
      .transition().duration(duration)
      .attr "opacity", 0

    waste.filter(".quote, .view-report-btn")
      .attr "opacity", 1
      .transition().duration(duration)
      .attr "opacity", 0


    waste.classed("exiting", true).call (exiting) ->
      if exiting.empty() then return callback()
      setTimeout ->
        exiting.remove()
        callback()
      , duration
