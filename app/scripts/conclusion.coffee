define ["d3", "underscore", "./clean", "./map"], (d3, _, clean, map) ->
  (props) ->
    clean.call @, ["#vectorMap", ".quote"], =>
      quote_sel = @select(".quote")
      if quote_sel.empty()
        quote_sel = @append("text").attr("class", "quote")

      top = 220
      quote_sel
        .attr("transform", "translate(#{ props.size[0]/2 }, #{ top })")
      tspan_sel = quote_sel.selectAll("tspan")
        .data "#{ props.quote }\n\n#{ props.attribution }".split("\n")
      tspan_sel.enter().append("tspan")
      tspan_sel
        .text (d) -> d or " "
        .attr
          "dy": 24
          "x": 0
      tspan_sel.exit().remove()

      button_sel = @select(".view-report-btn")
      if button_sel.empty()
        button_sel = @append("g").attr("class", "view-report-btn")
          .attr "opacity", 0
          .call ->
            @append("rect")
            @append("text")
      button_sel
        .attr "transform", "translate(#{ props.size[0]/2 }, 550)"
        .transition().duration(600).ease("cubic-out")
        .attr "opacity", 1
      button_sel.select("rect").attr
        "width": width = 139
        "height": height = 34
        "x": -width/2
        "y": -height/2
      button_sel.select("text").text("View Report").attr "dy": 5