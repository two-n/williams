define ["d3", "./clean", './trailing_bubble'], (d3, clean, TrailingBubble) ->

  (props) ->
    clean.call @, [".rows", ".x-axis", ".label"], =>

      trailing = TrailingBubble()

      index = _.indexBy d3.csv.parse(props.data), ""

      [width, height] = [@property("offsetWidth"), @property("offsetHeight")]

      rows = props.rows.map (d) -> index[d]
      max = d3.max(rows, (d) -> d3.max(props.bars.map (bar) -> parseFloat(d?[bar])))

      margin =
        left: 105
        right: 90
        top: 90
        bottom: 60

      innerWidth = width - margin.left - margin.right
      innerHeight = height - margin.top - margin.bottom

      xScale = d3.scale.linear().domain([0, max*1.1]).nice().range([0, innerWidth])

      yScale = d3.scale.ordinal()
        .domain([0...rows.length])
        .rangeBands([0, innerHeight], 0.1, 0.5)

      xAxis = d3.svg.axis()
        .scale(xScale)
        .orient("bottom")
        .tickValues(xScale.domain())
        .tickFormat (d) -> if d > 0 then d + "%" else d
        .tickPadding(8)

      barHeight = Math.floor yScale.rangeBand() / (props.bars.length + 1)

      rows_sel = @select(".rows")
      if rows_sel.empty()
        rows_sel = @append("g").attr("class", "rows")
      rows_sel.attr "transform", "translate(#{ margin.left }, #{ margin.top })"

      sel = rows_sel.selectAll(".row").data rows, (d) -> d?[""]
      sel.enter()
        .append("g")
        .attr("class", "row")
        .attr "transform", (d, i) -> "translate(0, #{ yScale(i) })"
        .attr "fill-opacity", 0
      sel.each (d) ->
        row_sel = d3.select(@)

        console.log sel

        if d?
          text_sel = row_sel.select("text")
          if text_sel.empty()
            text_sel = row_sel.append("text").attr "y", "-0.4em"
          tspan_sel = text_sel.selectAll("tspan").data(d[""].split(/\s/g))
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
          bar_sel.exit()
            .classed "exiting", true
            .transition().duration(600)
            .attr "width", 0
            .remove()

      sel
        .transition().duration(600)
        .attr "transform", (d, i) -> "translate(0, #{ yScale(i) })"
        .attr "fill-opacity", 1

      calloutSurface = @.select("g.calloutSurface")
      if calloutSurface.empty()
        calloutSurface = @.append("g").classed("calloutSurface", true)

      sel.each (row) ->
        d3.select(@)
          .selectAll(".bar:not(.exiting)")
            .on "mouseenter", (d,i) ->
              bubble = calloutSurface.selectAll('g.trailing-bubble').data([null])
              bubble.enter()
                .append "g"
                  .attr
                    class: "trailing-bubble"
              x = xScale parseFloat(row[d])
              y = yScale(i)

              point = d3.mouse(calloutSurface.node())
              vector = [0.25,-0.5]
              trailing
                .point(point)
                .vector(vector, 18)
                .text("LGBT,#{row["LGBT"]}")
                .subSpanText [{label: "Non-LGBT", value: row["Non-LGBT"] , bold: false}]
                .stroke "#A6A6AC"
              bubble.call trailing
            .transition()
            .duration(600)
            .ease("cubic-out")
            .attr "width", (d, i) ->
              xScale parseFloat(row[d])
            .attr "height", barHeight
            .attr "transform", (d, i) -> "translate(0, #{ i * barHeight })"
            .attr "fill", (d, i) -> if i is 0 then props.colors[0].value else "#D1D1D4"

      sel.exit()
        # .transition()
        # .ease("cubic-out")
        # .duration(600)
        # .attr "width", 0
        .remove()


      axis_sel = @select(".x-axis")
      if axis_sel.empty()
        axis_sel = @append("g").attr("class", "x-axis")
          .attr
            "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
            "fill-opacity": 0
            "stroke-opacity": 0
      else
        axis_sel.select(".halfway-line").remove()

      axis_sel.transition().duration(600).call(xAxis)
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
          "fill-opacity": 1
          "stroke-opacity": 1

      label_sel = @select(".label")
      if label_sel.empty()
        label_sel = @append("text").attr("class", "label")
          .attr "fill-opacity": 0
          .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
      label_sel.selectAll("tspan").remove()
      label_sel.transition().duration(600)
        .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
        .attr "text-anchor", "middle"
        .attr "y", 14
        .attr "fill-opacity": 1

      props.label.split("\n").forEach (text) ->
        label_sel
          .append("tspan")
          .text text
          .attr "dy", 15
          .attr "x", 0

