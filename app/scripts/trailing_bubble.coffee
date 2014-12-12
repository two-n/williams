define ['d3'], (d3) ->
  ->
    point = null
    vector = [-20, -20]
    width = 4#80
    mainTextHeight = 18
    text = "bubble"
    subSpanText = ""
    color = '#888'
    stroke = null

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

      whiteRect = sel.selectAll(".whiteRect").data([null])
      whiteRect.enter()
        .append('rect')
          .attr
            fill: color
            class: "whiteRect"
            stroke: 'white'
            "stroke-width": 5.5

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
            stroke: 'red'
            "stroke-width": 1.5

      arrowStroke = [ 'white', stroke, 'none']
      arrowStrokeWidth = [4, 2, 0]
      # Actually draws 2 paths, one without stroke (on top)
      # and one with stoke below
      path = sel.selectAll('path').data [null, null, null]
      path.enter()
        .insert('path', (d, i) -> body.node() if i isnt 2)
        .attr
          "fill":           color
          "pointer-events": "none"
          "stroke":         (d, i) -> arrowStroke[i] #if i == 0 then stroke else 'none'
          "stroke-width":   (d, i) -> arrowStrokeWidth[i] #if i == 0 then 2 else 0

      gText = sel.selectAll('g.trailing-bubble-text')
      if gText.empty()
        gText = sel.append('g').attr('class', 'trailing-bubble-text')

      mainText = gText.selectAll("text.mainText")
      if mainText.empty()
        mainText = gText.append('text')
      mainText
        .attr
          x: 9
          y: 6
          dy: 7
          'pointer-events': 'none'
          class: "mainText"
        .text(text)

      positionSubTextLine = (d,i) -> mainTextHeight + 16 + 15 * i
      subText = gText.selectAll("text.subText.subLabel").data(subSpanText)
      subText.enter().append("text")
        .attr
          class: "subLabel subText"
      subText
        .attr
          x: 9
          y: positionSubTextLine
        .text (d) -> d.label
        .classed("highlight",(d) -> d.bold)
      subText.exit().remove()

      subTextValue = gText.selectAll("text.subValue").data(subSpanText)
      subTextValue.enter().append("text")
        .attr
          fill: '#fff'
          class: "subValue subText"
          height: mainTextHeight
      subTextValue
        .attr
          y: positionSubTextLine
          x: () => Math.max mainText.node().getBBox().width - 30, 170
        .style
          fill: (d) -> if d.highlightValue then "#FF0055"
        .text (d) ->  d.value
        .classed("highlight",(d) -> d.bold)
      subTextValue.exit().remove()

      bbox = gText.node().getBBox()

      width = bbox.width + 19
      totalHeight = bbox.height + 9

      breakLine = body.selectAll("line.break")
      if breakLine.empty()
        breakLine = body.append('line')
      breakLine
        .attr
          x1: 0
          y1: mainTextHeight + 1
          y2: mainTextHeight + 1
          class: "break"
          stroke: stroke
          display: () => if subSpanText.length > 0 then "inherit" else "none"
      prep(breakLine)
        .attr
          x2: bbox.width + 19

      titleSplit = mainText.text().split(',')
      if titleSplit.length is 2
        mainValueData = [titleSplit[1]]
        mainText.text titleSplit[0]
      else
        mainValueData = []
      mainValue = gText.selectAll("text.mainValue").data(mainValueData)
      mainValue.enter().append("text")
        .attr
          "class" : "mainValue"
      mainValue
        .attr
          x: 170
          y: 6
          dy: 7
          'pointer-events': 'none'
        .text (d) -> d

      prep(body.selectAll('rect'))
        .attr
          fill: color
          width: width
          height: totalHeight
          stroke: stroke

      sel.selectAll('rect.whiteRect')
        .attr
          fill: color
          width: width
          height: totalHeight
          stroke: "white"

      registration = [
        point2[0] - (if vector[0] > 0 then r2+1 else width - r2-1)
        point2[1] + r2+1 - totalHeight
      ]

      bodyEnter.attr transform: "translate(#{registration})"
      # gText.attr transform: "translate(#{registration})"
      prep(body)
        .attr
          transform: "translate(#{registration})"
      prep(whiteRect)
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

    bubble.stroke = (s) ->
      return stroke if arguments.length == 0
      stroke = s
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
