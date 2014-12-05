define ["d3", "./trailing_bubble"], (d3, TrailingBubble) ->

  trailing = TrailingBubble()

  callout = (coords, d) ->
    bubble = @.selectAll('.trailing-bubble').data d
    bubble.exit()
      .remove()

    if d.length? and (d.length is 0)
      return

    vector = [0.25,-0.5]

    trailing
      .point([
          coords[0],coords[1]
        ])
      .vector(vector, 18)
      .color("#999")
      .text((d) -> d.countyName)
      # .subSpanText("#{dimension.color.value()(d) || ""}")

    bubble.enter()
      .append('g')
      .style('opacity', 0)
      .attr
        class: "trailing-bubble"
      .transition()
      .delay(100)
      .duration(100)
      .style('opacity', 1)

    bubble.call trailing
