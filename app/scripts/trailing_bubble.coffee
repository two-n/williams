define ['d3'], (d3) ->
  ->
    point = null
    vector = [-20, -20]
    width = 4#80
    height = 20
    text = "bubble"
    subSpanText = ""
    color = '#888'

    deg90 = Math.PI / 2
    r1 = .5
    r2 = 5

    prep = (sel) ->
      sel
        .transition()
        .duration(100)
        .ease('linear')

    bubble = (sel) ->
      point2 = [
        point[0] + vector[0]
        point[1] + vector[1]
      ]

      body = sel.selectAll('.trailing-bubble-body').data [null]
      bodyEnter = body.enter()
        .append('g')
          .attr
            class: 'trailing-bubble-body'
            "pointer-events": "none"
      bodyEnter
        .append('rect')
          .attr
            fill: color
            # rx: r2
            stroke: 'white'
            'stroke-width': 1.5

      # Actually draws 2 paths, one without stroke (on top)
      # and one with stoke below
      path = sel.selectAll('path').data [null, null]
      path.enter()
        .insert('path', (d, i) -> body.node() if i == 0)
        .attr
          "fill":           color
          "pointer-events": "none"
          "stroke":         (d, i) -> if i == 0 then 'white' else 'none'
          "stroke-width":   (d, i) -> if i == 0 then 2 else 0

      gText = sel.selectAll('g.trailing-bubble-text')
      if gText.empty()
        gText = sel.append('g').attr('class', 'trailing-bubble-text')

      mainText = gText.selectAll("text.mainText")
      if mainText.empty()
        mainText = gText.append('text')
      mainText
        .attr
          # fill: '#fff'
          x: 5
          y: 6
          dy: '.8em'
          'font-size': '.8em'
          'pointer-events': 'none'
          class: "mainText"
          height: height
        .text(text)

      subText = gText.selectAll("text.subLabel").data(subSpanText)
      subText.enter().append("text")
        .attr
          fill: '#fff'
          x: 5
          dy: '.8em'
          'font-size': '.8em'
          'pointer-events': 'none'
          class: "subLabel"
          height: height
      subText
        .attr
          y: (d,i) -> 30 + 17 * i
        .text (d) -> d.label
        .classed("bold",(d) -> d.bold)
      subText.exit().remove()

      subTextValue = gText.selectAll("text.subValue").data(subSpanText)
      subTextValue.enter().append("text")
        .attr
          fill: '#fff'
          x: 5
          dy: '.8em'
          'font-size': '.8em'
          'pointer-events': 'none'
          class: "subValue"
          height: height
      subTextValue
        .attr
          y: (d,i) -> 30 + 17 * i
          x: () => Math.max mainText.node().getBBox().width - 30, 140
          "text-anchor": "right"
        .style
          fill: (d) -> if d.highlightValue then "#FF0055"
        .text (d) -> d.value
        .classed("bold",(d) -> d.bold)
      subTextValue.exit().remove()

      bbox = gText.node().getBBox()

      width = bbox.width + 10
      totalHeight = bbox.height + 3

      breakLine = body.selectAll("line.break")
      if breakLine.empty()
        breakLine = body.append('line')
      breakLine
        .attr
          x1: 0
          y1: 25
          y2: 25
          class: "break"
          display: () => if subSpanText.length > 0 then "inherit" else "none"
      prep(breakLine)
        .attr
          x2: bbox.width + 10

      prep(body.select('rect'))
        .attr
          fill: color
          width: width
          height: totalHeight

      registration = [
        point2[0] - (if vector[0] > 0 then r2+1 else width - r2-1)
        point2[1] + r2+1 - totalHeight
      ]

      bodyEnter.attr transform: "translate(#{registration})"
      # gText.attr transform: "translate(#{registration})"
      prep(body)
        .attr
          transform: "translate(#{registration})"
      prep(gText)
        .attr
          transform: "translate(#{registration})"
      prep(path)
        .attr
          fill: color
          d: (d, i) ->
            getPath(point, r1, point2, r2)

    bubble.point = (pt) ->
      return point if arguments.length == 0
      point = pt
      bubble

    bubble.vector = (v, dist) ->
      return vector if arguments.length == 0
      vector = v
      if dist?
        mag = Math.sqrt vector[0]*vector[0] + vector[1]*vector[1]
        vector[0] *= dist/mag
        vector[1] *= dist/mag
      bubble

    bubble.text = (t) ->
      return text if arguments.length == 0
      text = t
      bubble

    bubble.color = (c) ->
      return color if arguments.length == 0
      color = c
      bubble

    bubble.subSpanText = (sST) ->
      return subSpanText if arguments.length is 0
      subSpanText = sST
      bubble

    getPath = (pt1, r1, pt2, r2) ->
        angle = Math.atan2 pt2[0] - pt1[0], pt2[1] - pt1[1]
        pt1 = [
          pt1[0] + 2 * Math.sin(angle)
          pt1[1] + 2 * Math.cos(angle)
        ]
        distance = Math.sqrt(
            Math.pow(pt2[0] - pt1[0], 2) +
            Math.pow(pt2[1] - pt1[1], 2)
        )
        rDiff = r1 - r2
        if distance+5 <= r2 then return "M0,0"

        theta = Math.asin(rDiff/distance)

        l11 = [
            pt1[0] + r1 * Math.cos(theta-angle)
            pt1[1] + r1 * Math.sin(theta-angle)
        ]
        l12 = [
            pt2[0] + r2 * Math.cos(theta-angle)
            pt2[1] + r2 * Math.sin(theta-angle)
        ]
        l21 = [
            pt1[0] + r1 * Math.cos(-theta-angle+Math.PI)
            pt1[1] + r1 * Math.sin(-theta-angle+Math.PI)
        ]
        l22 = [
            pt2[0] + r2 * Math.cos(-theta-angle+Math.PI)
            pt2[1] + r2 * Math.sin(-theta-angle+Math.PI)
        ]
        return "M#{l12}" +
            # "L#{pt1}L#{l22}" +
            "A#{r2},#{r2} 0,1,1 #{l22}" +
            "L#{l21}" +
            "A#{r1},#{r1} 0,0,1 #{l11}z"

    bubble # return it
