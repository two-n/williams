define ["d3", "underscore", "./clean"], (d3, _, clean) ->

  (props) ->
    clean.call @, [".lines", ".x-axis", ".y-axis", ".label"], =>
      index = _.indexBy d3.csv.parse(props.data), ""

      [width, height] = [@property("offsetWidth"), @property("offsetHeight")]

      lines = props.lines.map (d) ->
        line = _.clone(index[d])
        label = line[""]
        delete line[""]
        label: label
        points: _.sortBy _.pairs line

      margin =
        left: 45
        right: 62
        top: 20
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
        .tickFormat (d, i) -> if d in xScale.domain() then Number(d)
        .tickPadding(8)

      yAxis = d3.svg.axis()
        .scale(yScale)
        .orient("left")
        .tickValues(d3.range(yScale.domain()[0], yScale.domain()[1]+10, 10))
        .tickFormat (d, i) ->
          if d in [50, 100] then d + "%"
        .tickPadding(8)

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
        # .each ->
        #   length = @getTotalLength()
        #   d3.select(@).attr
        #     'stroke-dasharray': "#{length}px #{length}px"
        #     'stroke-dashoffset': "#{length}px"

      sel.transition()
        .attr "stroke-opacity", 1

      sel.select(".line")
        .transition().duration(600)
        .attr "stroke-opacity", 1
        # .attr 'stroke-dashoffset', 0
        # .each 'end', ->
        #   d3.select(@)
        #     .attr 'stroke-dasharray', null

      sel.exit()
        .remove()

      axis_sel = @select(".x-axis")
      if axis_sel.empty()
        axis_sel = @append("g").attr("class", "x-axis")
          .attr
            "transform": "translate(#{ margin.left }, #{ margin.top + innerHeight })"
            "fill-opacity": 0
            "stroke-opacity": 0

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

