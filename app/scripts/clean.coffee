define ["d3"], (d3) ->
  (deps = [], callback) ->
    selectors = [
      ".hook"
      ".rows"
      ".lines"
      ".pies"
      ".benchmarks"
      ".x-axis"
      ".y-axis"
      ".label"
      "#vectorMap"
      ".unscaledRegionOverlay"
      ".interactivityInstruction"
      ".calloutSurface"
      ".timeAxis"
      ".quote"
      ".view-report-btn"
    ]

    waste = @selectAll(selectors)
    waste = waste.filter(":not(#{ dep })") for dep in deps
    duration = 600

    waste.filter(".hook")
      .attr "fill-opacity": 1
      .transition().duration(duration).ease("cubic-out")
      .attr "fill-opacity": 0

    waste.filter("#vectorMap")
      .attr
        "fill-opacity" : 0
        "stroke-opacity" : 0

    waste.filter("#vectorMap").selectAll(".regionOverlay circle")
      .transition().duration(duration).ease("cubic-out")
      .attr "r", 0

    waste.filter(".unscaledRegionOverlay")
      .attr "opacity", 1
      .transition().duration(duration).ease("cubic-out")
      .attr "opacity", 0

    waste.filter(".timeAxis")
      .attr
        "fill-opacity": 1
        "stroke-opacity": 1
      .transition().duration(duration).ease("cubic-out")
      .attr
        "fill-opacity": 0
        "stroke-opacity": 0

    waste.filter(".calloutSurface")
      .attr
        "fill-opacity": 0
        "stroke-opacity": 0

    waste.filter(".x-axis, .y-axis").transition().duration(duration).ease("cubic-out")
      .attr
        "fill-opacity": 0
        "stroke-opacity": 0
      .selectAll(".halfway-line, .tick").attr "opacity": 0

    waste.filter(".label").transition().duration(duration).ease("cubic-out")
      .attr "fill-opacity": 0

    waste.filter(".rows").selectAll(".row")
      .transition().duration(duration).ease("cubic-out")
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
      .transition("dasharray").duration(duration).ease("cubic-out")
      .attr
        "stroke-dashoffset": 0
        "stroke-opacity": 0

    waste.filter(".pies").selectAll(".pie")
      .attr "opacity", 1
      .transition().duration(duration).ease("cubic-out")
      .attr "opacity", 0

    waste.filter(".benchmarks").selectAll(".benchmark")
      .attr "opacity", 1
      .transition().duration(duration).ease("cubic-out")
      .attr "opacity", 0

    waste.filter(".quote, .view-report-btn")
      .attr "opacity", 1
      .transition().duration(duration).ease("cubic-out")
      .attr "opacity", 0


    waste.classed("exiting", true).call (exiting) ->
      if exiting.empty() then return callback()
      setTimeout ->
        exiting.remove()
        callback()
      , duration
