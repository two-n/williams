define ["d3", "underscore", "./map"], (d3, _, map) ->
  conclusion = (props) ->
    map.call @,
      size: props.size
      split: true
      mode: "silhouette"
      fill: "light"


    quote_sel = @select(".quote")
    if quote_sel.empty()
      quote_sel = @append("text").attr("class", "quote")

    top = 220
    quote_sel
      .attr("transform", "translate(#{ props.size[0]/2 }, #{ top })")
    tspan_sel = quote_sel.selectAll(".line")
      .data props.quote.split("\n")
    tspan_sel.enter().append("tspan").attr("class", "line")
    tspan_sel
      .text (d) -> d or " "
      .attr
        "dy": 23
        "x": 0
    tspan_sel.exit().remove()

    quote_marks_sel = quote_sel.selectAll(".mark").data ["“", "” "]
    quote_marks_sel.enter().append("tspan").attr("class", "mark").text(String)
      .attr "x", (d, closing) ->
        if closing then 155 else -170
      .attr "y", (d, closing) ->
        if closing then 225 else 40
      .attr "text-anchor", (d, closing) -> if closing then "start" else "end"

    quote_marks_sel.exit().remove()


    button_sel = @select(".view-report-btn")
    if button_sel.empty()
      button_sel = @append("g").attr("class", "view-report-btn")
        .attr "opacity", 0
      button_sel.append("a")
        .attr "xlink:href", "http://williamsinstitute.law.ucla.edu/research/lgbt-divide-dec-2014/"
        .attr "target", "_blank"
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

  conclusion.deps = ["#vectorMap", ".quote", ".view-report-btn"]

  return conclusion
