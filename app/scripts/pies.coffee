define ["d3", "hammer"], (d3, Hammer) ->

  dispatch = d3.dispatch "hover"

  pies = (props) ->
    [width, height] = props.size

    index = _.indexBy d3.csv.parse(props.data), ""
    pies = props.pies.map (d) -> index[d]

    pies_sel = @select(".pies")
    if pies_sel.empty()
      pies_sel = @append("g").attr("class", "pies")

    if (underlay = pies_sel.select(".underlay")).empty()
      underlay = pies_sel.append("rect").attr "class", "underlay"
        .each (d, i) ->
          mc = Hammer(@, {preventDefault: true})
          mc.add( new Hammer.Press({ time: 0 }) )
          mc.on "press", -> dispatch.hover(null)

    underlay.attr
      "fill": "transparent"
      "width": width
      "height": height


    radius = Math.min width / 644 * 90, (height - 90) / (678 - 90) * 90
    innerRadius = radius * 72/90

    transform = (d, i) ->
      x = (i+0.5) / pies.length * (width - 100) + 50
      y = 90 + if i % 2 then (height - 90) * 2 / 3 else (height - 90) / 6
      "translate(#{ x }, #{ y })"
    sel = pies_sel.selectAll(".pie:not(.exiting)").data pies, (d) -> d?[""]
    sel.enter()
      .append("g")
      .attr("class", "pie")
      .attr "transform", transform
      .attr "opacity", 0

    sel.transition().duration(200).ease("cubic-out")
      .attr "transform", transform
      .attr "opacity", 1

    sel.each (d) ->
      pie_sel = d3.select(@)

      # circle_sel = pie_sel.select("circle")
      # if circle_sel.empty()
      #   circle_sel = pie_sel.append("circle")
      # circle_sel
      #   .attr
      #     "fill": "#FF9C00"
      #     "r": 71

      text_sel = pie_sel.select("text")
      if text_sel.empty()
        text_sel = pie_sel.append("text")
      text_sel.text(d[""])
        .classed "faded", props.ethnicity?
        .attr "text-anchor", "middle"
        .attr "dy", -5
        .transition().duration(200).ease("cubic-out")
        .attr "y", radius + 30

      split_pattern = /\s|\/a2/

      slices_sel = pie_sel.select(".slices")
      if slices_sel.empty()
        slices_sel = pie_sel.append("g").attr("class", "slices")
      arc = d3.svg.arc().outerRadius(innerRadius)
      pie = d3.layout.pie()
        .sort(null)
        .value (x) -> parseFloat(d[x])
      fill = (d, i) ->
        if props.ethnicity?
          if props.ethnicity is d.data.split(split_pattern)[0]
            props.colors[0].value[0]
          else
            props.colors[0].value.slice(-1)[0]
        else
          props.colors[0].value[i]
      registerPressHandler = (d) ->
        mc = Hammer(@, {preventDefault: true})
        mc.add( new Hammer.Press({ time: 0 }) )
        mc.on "press", -> dispatch.hover(d.data.split(split_pattern)[0])
      slice_sel = slices_sel.selectAll(".arc")
        .data(pie(props["slices"]))
      slice_sel.enter().append("path")
        .attr("class", "arc")
        .style "fill", fill
        .on "mouseenter", (d) -> dispatch.hover(d.data.split(split_pattern)[0])
        .on "mouseleave", -> dispatch.hover(null)
        .each registerPressHandler
      slice_sel
        .style("cursor", "pointer")
        # .style("stroke", (d, i) -> "#EDEDEE")
        # .style("stroke-width", 1)
        .transition().duration(200).ease("cubic-out")
        .attr("d", arc)
        .style "fill", fill

      donut_sel = pie_sel.select(".donut")
      if donut_sel.empty()
        donut_sel = pie_sel.append("g").attr("class", "donut")
      arc = d3.svg.arc()
        .innerRadius(innerRadius + 4)
        .outerRadius(radius)
      pie = d3.layout.pie().sort(null).value (x) -> parseFloat(d[x])
      fill = (d, i) ->
        if props.ethnicity?
          if props.ethnicity is d.data.split(split_pattern)[0]
            props.colors[1].value[0]
          else
            props.colors[1].value.slice(-1)[0]
        else
          props.colors[1].value[i]
      donut_slice_sel = donut_sel.selectAll(".arc")
        .data(pie(props["outer-slices"]))
      donut_slice_sel.enter().append("path")
        .attr("class", "arc")
        .style "fill", fill
        .on "mouseenter", (d) -> dispatch.hover(d.data.split(split_pattern)[0])
        .on "mouseleave", -> dispatch.hover(null)
        .each registerPressHandler
      donut_slice_sel
        .style("stroke", (d, i) -> "#EDEDEE")
        .style("stroke-width", 1)
        .style("cursor", "pointer")
        .transition().duration(200).ease("cubic-out")
        .attr("d", arc)
        .style "fill", fill

      ethnicity_sel = pie_sel.select(".ethnicity-stats")
      if props.ethnicity?
        if ethnicity_sel.empty()
          ethnicity_sel = pie_sel.append("g").attr("class", "ethnicity-stats")
            .attr "transform", "translate(0, #{ radius + 30 })"
        ethnicity_sel.transition().duration(200).ease("cubic-out")
          .attr "transform", "translate(0, #{ radius + 30 })"
          .attr("opacity", 1)
        ethnicity_sel.text("")  # clear

        ethnicity_sel.append("line").attr
          stroke: props.colors[0].value[0]
          x1: -innerRadius
          x2: innerRadius
        ethnicity_sel.append("text").attr("class", "name")
          .text props.ethnicity
          .attr "y", 12
        ethnicity_sel.append("line").attr
          stroke: props.colors[0].value[0]
          x1: -innerRadius
          x2: innerRadius
          y1: 15
          y2: 15
        ethnicity_sel.append("text").attr("class", "marker")
          .text "LGBT"
          .attr "x", -innerRadius/2
          .attr "y", 30

        ethnicity_sel.append("text").attr("class", "percentage")
          .text _.find(_.pairs(d), (x) -> ~x[0].search("[^-]LGBT") and ~x[0].search(props.ethnicity))[1]
          .attr "x", -innerRadius/2
          .attr "y", 57

        ethnicity_sel.append("line").attr
          stroke: props.colors[0].value[0]
          y1: 15 + 5
          y2: 15 + 53 - 4

        ethnicity_sel.append("text").attr("class", "marker")
          .text "Non-LGBT"
          .attr "x", innerRadius/2
          .attr "y", 30

        ethnicity_sel.append("text").attr("class", "percentage")
          .text _.find(_.pairs(d), (x) -> ~x[0].search("Non-LGBT") and ~x[0].search(props.ethnicity))[1]
          .attr "x", innerRadius/2
          .attr "y", 57
        ethnicity_sel.append("line").attr
          stroke: props.colors[0].value[0]
          x1: -innerRadius
          x2: innerRadius
          y1: 15 + 53
          y2: 15 + 53

      else
        ethnicity_sel
          .attr("opacity", 1)
          .transition().duration(200).ease("cubic-out")
          .attr("opacity", 0)
          .remove()

    sel.exit().remove()

  pies.deps = [".pies"]

  d3.rebind pies, dispatch, "on"
