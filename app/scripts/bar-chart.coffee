define ["d3", "./callout"], (d3, callout) ->

  barChart = (props) ->
    index = _.indexBy d3.csv.parse(props.data), ""

    [width, height] = props.size

    rows = props.rows.map (d) -> index[d]
    max = d3.max(rows, (d) -> d3.max(props.bars.map (bar) -> parseFloat(d?[bar])))

    margin =
      left: props.margin?.left ? 105
      right: props.margin?.right ? 90
      top: props.margin?.top ? 180
      bottom: props.margin?.bottom ? 60

    innerWidth = width - margin.left - margin.right
    innerHeight = height - margin.top - margin.bottom

    xScale = d3.scale.linear()
      .domain(props.bounds ? [0, max]).nice()
      .range([0, innerWidth])

    yScale = d3.scale.ordinal()
      .domain([0...rows.length])
      .rangeBands([0, innerHeight], 0.1, 0.5)

    xAxis = d3.svg.axis()
      .scale(xScale)
      .orient("bottom")
      .ticks(4)
      # .tickValues(xScale.domain())
      .tickFormat (d) -> if d > 0 then d + "%" else d
      .tickPadding(8)

    barHeight = Math.floor yScale.rangeBand() / 3
    if props.bars.length is 1 then barHeight *= 2

    rows_sel = @select(".rows")
    if rows_sel.empty()
      rows_sel = @append("g").attr("class", "rows")
    rows_sel.attr "transform", "translate(#{ margin.left }, #{ margin.top })"

    sel = rows_sel.selectAll(".row:not(.exiting)").data rows, (d) -> d?[""]
    sel.enter()
      .append("g")
      .attr("class", "row")
      .attr "transform", (d, i) -> "translate(0, #{ yScale(i) })"
      .attr "fill-opacity", 0
    sel.each (row, row_i) ->
      row_sel = d3.select(@)

      if row?
        text_sel = row_sel.select("text")
        if text_sel.empty()
          text_sel = row_sel.append("text").attr "y", "-0.4em"
        tspan_sel = text_sel.selectAll("tspan").data(row[""].split(/\s/g))
        tspan_sel.enter().append("tspan")
            .text String
            .attr "x", 0
            .attr "dx", -10
            .attr "dy", "1.2em"
        tspan_sel.exit().remove()

        bar_sel = row_sel.selectAll(".bar").data(props.bars)
        bar_sel.enter().append("rect").attr("class", "bar")
          .attr "width", 0
          .attr "height", barHeight
          .attr "transform", (d, i) -> "translate(0, #{ i * barHeight })"
          .attr "fill", (d, i) -> if i is 0 then props.colors[0].value else "#D1D1D4"
        bar_sel.transition().duration(600).ease("cubic-out")
          .attr "height", barHeight
          .attr "transform", (d, i) -> "translate(0, #{ i * barHeight })"
          .attr "fill", (d, i) -> if i is 0 then props.colors[0].value else "#D1D1D4"
        bar_sel.transition("width").duration(600).ease("cubic-out")
          .delay (d, i) -> row_i * 25 + i * 100
          .attr "width", (d, i) -> xScale parseFloat(row[d])
        bar_sel.exit()
          .classed "exiting", true
          .transition().duration(600).ease("cubic-out")
          .delay((d,i) -> row_i*25 + i*100)
          .attr "width", 0
          .remove()

    sel
      .transition().duration(600).ease("cubic-out")
      .attr "transform", (d, i) -> "translate(0, #{ yScale(i) })"
      .attr "fill-opacity", 1

    calloutSurface = @

    formatCalloutData = (row) ->
      toRet = {}
      if row["LGBT"]?
        toRet.name = "LGBT,#{row["LGBT"]}"
        if props.bars.length > 1
          toRet.subSpanText = [{label: "Non-LGBT", value: row["Non-LGBT"] , bold: false}]
        else
          toRet.subSpanText = []
      else
        toRet.name = "MSM* population,#{Math.round(row["MSM* population"])}"
        if props.bars.length > 1
          toRet.subSpanText = [{label: "All population", value: Math.round(row["All population"]) , bold: false}]
        else
          toRet.subSpanText = []
        #   names = ["LGBT", "Non-LGBT"]
        # else
        #   names = ["MSM* population","All population"]
      toRet.stroke = "#A6A6AC"
      [toRet]


    sel.each (row) ->
      d3.select(@)
        .selectAll(".bar:not(.exiting)")
          .on "mouseleave", ->
            callout.call calloutSurface, null, []
          .on "mousemove", (d,i) ->
            bubble = calloutSurface.selectAll('g.trailing-bubble').data([null])
            bubble.enter()
              .append "g"
                .attr
                  class: "trailing-bubble"
                  opacity: 0
                .transition().duration(500)
                  .attr
                    opacity: 1
            x = xScale parseFloat(row[d])
            y = yScale(i)

            point = d3.mouse(calloutSurface.node())
            vector = [0.25,-0.5]
            callout.call calloutSurface, point, formatCalloutData(row)
          .transition()
          .duration(600)
          .ease("cubic-out")
          .attr "width", (d, i) ->
            xScale parseFloat(row[d])
          .attr "height", barHeight
          .attr "transform", (d, i) -> "translate(0, #{ i * barHeight })"
          .attr "fill", (d, i) -> if i is 0 then props.colors[0].value else "#D1D1D4"

    exit = sel.exit()
      .transition().duration(600).ease("cubic-out")
      .attr "fill-opacity", 0
    exit.selectAll(".bar").attr "width", 0
    exit.remove()


    benchmarks_sel = @select(".benchmarks")
    if benchmarks_sel.empty()
      benchmarks_sel = @append("g").attr("class", "benchmarks")
    benchmarks_sel.attr("transform", "translate(#{margin.left}, #{margin.top})")
    benchmark_sel = benchmarks_sel.selectAll(".benchmark")
      .data (if props.benchmark? then props.bars else []), String
    benchmark_sel.enter().append("g").attr("class", "benchmark")
      .call ->
        @append("line").attr
          stroke: (d, i) ->
            color = if i is 0 then props.colors[0].value else "#D1D1D4"
            d3.rgb(color).darker(0.5)
        @append("text").attr("class", "top").attr("y", -24).attr("x", -2)
        @append("text").attr("class", "bottom").attr("y", -12).attr("x", -2)

    benchmark_sel.transition().duration(600)
      .attr "text-anchor", (d, i) -> props["benchmark-orientation"]?[i] ? "start"
      .attr "transform", (bar) ->
        x = xScale parseFloat(index[props.benchmark][bar])
        "translate(#{ x }, 0)"
      # .tween "value", (bar, i) ->
      #   a = d3.select(@).attr("data-value")
      #   interpolateValue = d3.interpolate a ? 0, parseFloat(index[props.benchmark][bar])
      #   (t) =>
      #     value_t = interpolateValue(t)
      #     d3.select(@)
      #       .attr "data-value", value_t
      #       .attr "transform", (bar) ->
      #         x = xScale value_t
      #         "translate(#{ x }, 0)"
      #       .select("text.bottom")
      #         .text (bar) -> "#{ bar } #{ Math.round(value_t) }%"
      .select("line").attr
        y2: yScale(rows.length-1) + yScale.rangeBand()
        stroke: (d, i) ->
          color = if i is 0 then props.colors[0].value else "#D1D1D4"
          d3.rgb(color).darker(0.5)

    benchmark_sel.select("text.top")
      .text("National Avg")
      .attr
        fill: (d, i) ->
          color = if i is 0 then props.colors[0].value else "#D1D1D4"
          d3.rgb(color).darker(0.5)
    benchmark_sel.select("text.bottom")
      .text (bar) -> "#{ bar } #{ parseFloat(index[props.benchmark][bar]) }%"
      .attr
        fill: (d, i) ->
          color = if i is 0 then props.colors[0].value else "#D1D1D4"
          d3.rgb(color).darker(0.5)

    benchmark_sel.exit().remove()


    axis_sel = @select(".x-axis")
    if axis_sel.empty()
      axis_sel = @append("g").attr("class", "x-axis")
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
          "fill-opacity": 0
          "stroke-opacity": 0
    else
      axis_sel.select(".halfway-line").remove()

    axis_sel.transition().duration(600).ease("cubic-out").call(xAxis)
      .attr
        "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
        "fill-opacity": 1
        "stroke-opacity": 1

    label_sel = @select(".label")
    if label_sel.empty()
      label_sel = @append("text").attr("class", "label")
        .attr "fill-opacity": 0
        .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
    # label_sel.remove()
    label_sel.transition().duration(600).ease("cubic-out")
      .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
      .attr "text-anchor", "middle"
      .attr "y", 27
      .attr "fill-opacity": 1

    tspan_sel = label_sel.selectAll("tspan").data props.label.split("\n"), Math.random
    tspan_sel.enter().append("tspan")
      .text String
      .attr "dy", 15
      .attr "x", 0
    tspan_sel.exit().remove()

  barChart.deps = [".rows", ".x-axis", ".benchmarks", ".label"]

  return barChart
