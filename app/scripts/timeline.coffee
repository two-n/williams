define ["d3", "underscore", "hammer", "./clean", "./trailing_bubble"], (d3, _, Hammer, clean, TrailingBubble) ->
  trailing = TrailingBubble()

  timeline = (props, focusedYear) ->
    context = @
    clean.call @, [".lines", ".x-axis", ".y-axis", ".label"], =>
      index = _.indexBy d3.csv.parse(props.data), ""

      [width, height] = props.size

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
        top: 140
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

      halfwayline_sel = axis_sel.select(".halfway-line")
      if halfwayline_sel.empty()
        halfwayline_sel = axis_sel.append("line")
          .attr("class", "halfway-line")
          .attr("opacity", 0)
      halfwayline_sel
        .attr
          "x1": 0
          "x2": innerWidth
          "y1": -innerHeight / 2
          "y2": -innerHeight / 2

      axis_sel.transition().duration(600).ease("cubic-out").call(xAxis)
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

      axis_sel.transition().duration(600).ease("cubic-out").call(yAxis)
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top })"
          "fill-opacity": 1
          "stroke-opacity": 1

      fifty_label = axis_sel.selectAll(".tick").filter (d, i) -> i is 5
        .attr "opacity", 0

      halfwayline_sel.transition("opacity").delay(1000).duration(300)
        .each "start", ->
          fifty_label.transition("opacity").duration(300).attr "opacity", 1
        .attr "opacity": 1

      label_sel = @select(".label")
      if label_sel.empty()
        label_sel = @append("text").attr("class", "label")
          .attr "fill-opacity": 0
          .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
      label_sel.selectAll("tspan").remove()
      label_sel.transition().duration(600).ease("cubic-out")
        .attr "transform", "translate(#{ margin.left + innerWidth/2 }, #{ margin.top + innerHeight })"
        .attr "text-anchor", "middle"
        .attr "y", 23
        .attr "fill-opacity": 1

      props.label.split("\n").forEach (text) ->
        label_sel
          .append("tspan")
          .text text
          .attr "dy", 15
          .attr "x", 0


      lines_sel = @select(".lines:not(.exiting)")
      if lines_sel.empty()
        lines_sel = @append("g").attr("class", "lines")
      lines_sel.attr "transform", "translate(#{ margin.left }, #{ margin.top })"

      sel = lines_sel.selectAll(".line").data lines, (d) -> d?.label
      generate_line = d3.svg.line()
        .x (d) -> xScale(+d[0])
        .y (d) -> yScale(+d[1])
      sel.enter().append("path")
        .attr "class", "line"
        .attr "fill", "none"
        .attr "stroke", (d) -> _.findWhere(props.colors, label: d.label).value
        .attr "stroke-width", 4
        .attr "stroke-opacity", 0
        .attr "d", (d) -> generate_line(d.points)
        .each ->
          length = @getTotalLength()
          d3.select(@).attr
            "stroke-dasharray": "#{length}px #{length}px"
            "stroke-dashoffset": "#{length}px"

      sel.transition("dasharray").duration(2000).ease("cubic-out")
        .attr "stroke-opacity", 1
        .attr "stroke-dashoffset", 0
        .each "end", ->
          d3.select(@).attr "stroke-dasharray", null

      sel.transition("d").duration(600).ease("cubic-out")
        .attr "d", (d) -> generate_line(d.points)

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
        .style
          "pointer-events": "none"
      circle_sel
        .transition().duration(75).ease("cubic-out")
        .attr
          "r": 4
          "cx": -> xScale focusedYear
          "cy": (d) -> yScale index[d][focusedYear]
      circle_sel.exit()
        .transition().duration(75).ease("cubic-out")
        .attr "r": 0
        .remove()


      overlay_sel = lines_sel.select(".overlay")
      if overlay_sel.empty()
        overlay_sel = lines_sel.append("rect").attr("class", "overlay")
          .on "mousemove", ->
            year = _.min years, (year) => Math.abs(year - xScale.invert(d3.mouse(@)[0]))
            timeline.call(context, props, year)
          .on "mouseleave", ->
            timeline.call(context, props, null)
          # .each ->
          #   mc = Hammer(@, {preventDefault: true})
          #   mc.on "panmove", (event) ->
          #     year = _.min years, (year) => Math.abs(year - xScale.invert(event.center.pageX))
          #     timeline.call(context, props, year)
          #   mc.on "panend", ->
          #     timeline.call(context, props, null)
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

      vectorsLeft = [[0.01,-0.5],[0.25,-0.5],[0.25,-0.5],[0.15,0.5],[0.25,-0.5]]
      vectorsRight = [[-0.01,-0.5],[-0.25,0.5],[-0.25,-0.5],[-0.15,0.5],[-0.25,-0.5]]
      distancesLeft = [7,28,18,28,18]
      distancesRight = [7,28,18,28,18]
      bubbleData = if focusedLines.length > 0 then ["Public Optinions"].concat focusedLines else []
      bubbleData.forEach (d,i) -> console.log d,i
      overlaySurface = @
      bubble = @.selectAll('g.trailing-bubble').data(bubbleData)
      bubble.enter()
        .append('g')
        .attr
          class: "trailing-bubble"
          opacity: 0
        .transition().duration(300)
          .attr
            "opacity": 1
      bubble
        .each (d, i) ->
          screenRight = xScale(focusedYear) > overlaySurface.node().getBBox().width/2

          if i > 0
            x = xScale(focusedYear)
            y = yScale(index[d][focusedYear])
          else
            x = xScale(focusedYear)
            y = yScale(index["Always Wrong"][focusedYear]) - 50
            if screenRight then x -= 8 else x += 8
          point = [x,y]

          if screenRight
            vector = vectorsRight[i]
          else
            vector = vectorsLeft[i]

          if i > 0
            text = "#{d}, #{index[d][focusedYear]}%"
          else
            text = "Public Opinions, #{focusedYear}"

          trailing
            .point(point)
            .vector(vector, if screenRight then distancesRight[i] else distancesLeft[i])
            .text(text)
            .stroke "#FF0055"
          if i is 0
            trailing.color "#FF0055"
            trailing.mainTextColor "#FFF"
          else
            trailing.color "#FFF"
            trailing.mainTextColor null
          d3.select(@).call trailing
        .attr
          "transform": "translate(#{ margin.left }, #{ margin.top })"


      bubble.exit().remove()
