define ["d3", "./clean"], (d3, clean) ->

  dispatch = d3.dispatch "hover"

  pies = (props) ->
    clean.call @, [".pies"], =>
      [width, height] = props.size

      index = _.indexBy d3.csv.parse(props.data), ""
      pies = props.pies.map (d) -> index[d]

      pies_sel = @select(".pies")
      if pies_sel.empty()
        pies_sel = @append("g").attr("class", "pies")

      transform = (d, i) ->
        x = (i+0.5) / pies.length * (width - 100) + 50
        y = if i % 2 then height * 2 / 3 else height / 6
        "translate(#{ x }, #{ y })"
      sel = pies_sel.selectAll(".pie").data pies, (d) -> d?[""]
      sel.enter()
        .append("g")
        .attr("class", "pie")
        .attr "transform", transform
        .attr "opacity", 0

      sel.transition().duration(600)
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
          .attr
            "text-anchor": "middle"
            "y": 115

        split_pattern = /\s|\/a2/

        slices_sel = pie_sel.select(".slices")
        if slices_sel.empty()
          slices_sel = pie_sel.append("g").attr("class", "slices")
        arc = d3.svg.arc().outerRadius(72)
        pie = d3.layout.pie()
          .sort(null)
          .value (x) -> parseFloat(d[x])
        slice_sel = slices_sel.selectAll(".arc")
          .data(pie(props["slices"]))
        slice_sel.enter().append("path")
          .attr("class", "arc")
          .on "mouseenter", (d) -> dispatch.hover(d.data.split(split_pattern)[0])
          .on "mouseleave", -> dispatch.hover(null)
        slice_sel
          .attr("d", arc)
          .style "fill", (d, i) ->
            if props.ethnicity?
              if props.ethnicity is d.data.split(split_pattern)[0]
                props.colors[0].value[0]
              else
                props.colors[0].value.slice(-1)[0]
            else
              props.colors[0].value[i]
          # .style("stroke", (d, i) -> "#EDEDEE")
          # .style("stroke-width", 1)
          .style("cursor", "pointer")

        donut_sel = pie_sel.select(".donut")
        if donut_sel.empty()
          donut_sel = pie_sel.append("g").attr("class", "donut")
        arc = d3.svg.arc()
          .innerRadius(76)
          .outerRadius(76 + 14)
        pie = d3.layout.pie()
          .sort(null)
          .value (x) -> parseFloat(d[x])
        donut_slice_sel = donut_sel.selectAll(".arc")
          .data(pie(props["outer-slices"]))
        donut_slice_sel.enter().append("path")
          .attr("class", "arc")
          .on "mouseenter", (d) -> dispatch.hover(d.data.split(split_pattern)[0])
          .on "mouseleave", -> dispatch.hover(null)
        donut_slice_sel
          .attr("d", arc)
          .style "fill", (d, i) ->
            if props.ethnicity?
              if props.ethnicity is d.data.split(split_pattern)[0]
                props.colors[1].value[0]
              else
                props.colors[1].value.slice(-1)[0]
            else
              props.colors[1].value[i]
          .style("stroke", (d, i) -> "#EDEDEE")
          .style("stroke-width", 1)
          .style("cursor", "pointer")

        ethnicity_sel = pie_sel.select(".ethnicity-stats")
        if props.ethnicity?
          if ethnicity_sel.empty()
            ethnicity_sel = pie_sel.append("g").attr("class", "ethnicity-stats")
              .attr "transform", "translate(0, 119)"
          ethnicity_sel.transition().duration(150)
            .attr "transform", "translate(0, 119)"
            .attr("opacity", 1)
          ethnicity_sel.text("")  # clear

          ethnicity_sel.append("line").attr
            stroke: props.colors[0].value[0]
            x1: -77
            x2: 77
          ethnicity_sel.append("text").attr("class", "name")
            .text props.ethnicity
            .attr "y", 12
          ethnicity_sel.append("line").attr
            stroke: props.colors[0].value[0]
            x1: -77
            x2: 77
            y1: 15
            y2: 15
          ethnicity_sel.append("text").attr("class", "marker")
            .text "LGBT"
            .attr "x", -77/2
            .attr "y", 30

          ethnicity_sel.append("text").attr("class", "percentage")
            .text _.find(_.pairs(d), (x) -> ~x[0].search("[^-]LGBT") and ~x[0].search(props.ethnicity))[1]
            .attr "x", -77/2
            .attr "y", 57

          ethnicity_sel.append("line").attr
            stroke: props.colors[0].value[0]
            y1: 15 + 5
            y2: 15 + 53 - 4

          ethnicity_sel.append("text").attr("class", "marker")
            .text "Non-LGBT"
            .attr "x", 77/2
            .attr "y", 30

          ethnicity_sel.append("text").attr("class", "percentage")
            .text _.find(_.pairs(d), (x) -> ~x[0].search("Non-LGBT") and ~x[0].search(props.ethnicity))[1]
            .attr "x", 77/2
            .attr "y", 57
          ethnicity_sel.append("line").attr
            stroke: props.colors[0].value[0]
            x1: -77
            x2: 77
            y1: 15 + 53
            y2: 15 + 53

        else
          ethnicity_sel
            .attr("opacity", 1)
            .transition().duration(150)
            .attr("opacity", 0)
            .remove()


      sel.exit().remove()


  d3.rebind pies, dispatch, "on"
