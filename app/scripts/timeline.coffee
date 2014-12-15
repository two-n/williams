define ["d3", "underscore", "./clean", "./trailing_bubble"], (d3, _, clean, TrailingBubble) ->

  trailing = TrailingBubble()

  timeline = (props, focusedYear) ->
    context = @
    clean.call @, [".lines", ".x-axis", ".y-axis", ".label"], =>
      index = _.indexBy d3.csv.parse(props.data), ""

      [width, height] = [@property("offsetWidth"), @property("offsetHeight")]

      lines = props.lines.map (d) ->
        line = _.clone(index[d])
        label = line[""]
        delete line[""]
        label: label
        points: _.sortBy _.pairs line

      years = lines[0].points.map (point) -> +point[0]

      margin =
        left: 45
        right: 62
        top: 50
        bottom: 60

      innerWidth = width - margin.left - margin.right
      innerHeight = height - margin.top - margin.bottom

      xScale = d3.scale.linear()
        .domain([1970, 2015])
        .range([0, innerWidth])

      yScale = d3.scale.linear()
        .domain([0, 100])
        .range([innerHeight, 0])

      xAxis = d3.svg.axis()
        .scale(xScale)
        .orient("bottom")
        .tickValues(d3.range(xScale.domain()[0], xScale.domain()[1]+5, 5))
        .tickFormat (d) -> if d in xScale.domain() then Number(d)
        .tickPadding(8)

      yAxis = d3.svg.axis()
        .scale(yScale)
        .orient("left")
        .tickValues(d3.range(yScale.domain()[0], yScale.domain()[1]+10, 10))
        .tickFormat (d) ->
          if d in [50, 100] then d + "%"
        .tickPadding(6)

      axis_sel = @select(".x-axis")
      if axis_sel.empty()
        axis_sel = @append("g").attr("class", "x-axis")
          .attr
            "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
            "fill-opacity": 0
            "stroke-opacity": 0

      halfwayline_sel = axis_sel.append("line").attr("class", "halfway-line")
        .attr
          "x1": 0
          "x2": innerWidth
          "y1": -innerHeight / 2
          "y2": -innerHeight / 2
          "opacity": 0

      axis_sel.transition().duration(600).call(xAxis)
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
          "fill-opacity": 1
          "stroke-opacity": 1

      axis_sel = @select(".y-axis")
      if axis_sel.empty()
        axis_sel = @append("g").attr("class", "y-axis")
          .attr
            "transform": "translate(#{ margin.left }, #{ margin.top })"
            "fill-opacity": 0
            "stroke-opacity": 0

      axis_sel.transition().duration(600).call(yAxis)
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top })"
          "fill-opacity": 1
          "stroke-opacity": 1

      fifty_label = axis_sel.selectAll(".tick").filter (d, i) -> i is 5
        .attr "opacity", 0

      halfwayline_sel.transition().delay(1000).duration(300)
        .each "start", ->
          fifty_label.transition().duration(300).attr "opacity", 1
        .attr "opacity": 1

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


      lines_sel = @select(".lines")
      if lines_sel.empty()
        lines_sel = @append("g").attr("class", "lines")
      lines_sel.attr "transform", "translate(#{ margin.left }, #{ margin.top })"

      sel = lines_sel.selectAll(".line").data lines, (d) -> d?.label
      generate_line = d3.svg.line()
        .x (d) -> xScale(+d[0])
        .y (d) -> yScale(+d[1])
      sel.enter()
        .append("path")
        .attr("class", "line")
        .attr("d", (d) -> generate_line(d.points))
        .attr("stroke-width", 4)
        .attr("stroke", (d) -> _.findWhere(props.colors, label: d.label).value)
        .attr("fill", "none")
        .attr "stroke-opacity", 0
        .each ->
          length = @getTotalLength()
          d3.select(@).attr
            "stroke-dasharray": "#{length}px #{length}px"
            "stroke-dashoffset": "#{length}px"

      sel.transition().duration(2000).ease("cubic-out")
        .attr "stroke-opacity", 1
        .attr "stroke-dashoffset", 0
        .each "end", ->
          d3.select(@).attr "stroke-dasharray", null

      sel.exit().remove()


      focusedLines = if focusedYear? then props.lines else []
      circle_sel = lines_sel.selectAll("circle").data(focusedLines, String)
      circle_sel.enter().append("circle")
        .attr
          "r": 0
          "fill": props.colors[0].value
          "stroke": "white"
          "stroke-width": 1.5
          "cx": -> xScale focusedYear
          "cy": (d) -> yScale index[d][focusedYear]
      circle_sel
        .transition().duration(75).ease("cubic-out")
        .attr
          "r": 4
          "cx": -> xScale focusedYear
          "cy": (d) -> yScale index[d][focusedYear]
      circle_sel.exit()
        .transition().duration(75)
        .attr "r": 0
        .remove()


      overlay_sel = lines_sel.select(".overlay")
      if overlay_sel.empty()
        overlay_sel = lines_sel.append("rect").attr("class", "overlay")
      overlay_sel
        .attr
          "fill": "transparent"
          "width": innerWidth
          "height": innerHeight
        .style
          "cursor": "pointer"
        .on "mousemove", ->
          year = _.min years, (year) => Math.abs(year - xScale.invert(d3.mouse(@)[0]))
          timeline.call(context, props, year)
        .on "mouseleave", ->
          year = _.min years, (year) => Math.abs(year - xScale.invert(d3.mouse(@)[0]))
          timeline.call(context, props, null)


      bubble = @.selectAll('g.trailing-bubble').data(focusedLines)
      bubble.enter()
        .append('g')
        .attr
          class: "trailing-bubble"
          opacity: 0
      bubble
        .each (d, i) ->
          x = xScale(focusedYear)
          y = yScale(index[d][focusedYear])
          point = [x,y]
          vector = [0.25,-0.5]
          # series = dimension.series d

          trailing
            .point(point)
            .vector(vector, 18)
            .text("#{d}, #{index[d][focusedYear]}%")
            .stroke "#FF0055"
          d3.select(@).call trailing
        .attr
          "opacity": 1
          "transform": "translate(#{ margin.left }, #{ margin.top })"
