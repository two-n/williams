require.config
  paths:
    "d3": "vendor/d3/d3.min"
    "topojson": "vendor/topojson/topojson"
    "underscore": "vendor/underscore/underscore"


define ["d3", "underscore", "./graphics", "./map", "./dropdown", "./bar-chart", "./timeline", "./pies"], (d3, _, graphics, map, dropdown, barChart, timeline, pies) ->
  # colors = ["#EDEDEE", "#D1D1D4", "#A6A6AC", "#797980", "#38383C", "#FF0055", "#FF9C00", "#FFDF00", "#00C775", "#0075CA", "#9843A0"]
  colors = ["#EDEDEE", "#D1D1D4", "#A6A6AC", "#797980", "#38383C", "#FF0055", "#FF9C00", "#ECD000", "#00C775", "#0075CA", "#9843A0"]
  currentProps = null

  state =
    transitioningScrollTop: false
    path: null
    ethnicity: "black"

  prevNav = null

  route = (path) ->
    if state.path is path then return
    state.path = path

    # TODO see http://stackoverflow.com/a/23924886 -- test iOS Chrome
    window.location.replace("#" + path)

    path or= "/introduction"
    if not ~path.slice(1).indexOf("\/")
      path += "/1"
    render _.findWhere graphics, url: path

  render = (props) ->
    if not props? then return
    currentProps = props

    currentColor = null

    currentColor = null

    # story
    lastChapter = null
    d3.select(".story")
      .selectAll(".chapter")
      .classed("active", false)
      .each ->
        if @offsetTop <= document.body.scrollTop
          lastChapter = d3.select(@).datum()

    d3.select(".story")
      .selectAll(".show-me")
      .classed("current", false)
      .filter ->
        d3.select(@).attr("href").slice(1) is props.url
      .classed("current", true)
      .each ->
        currentChapter = d3.select(@parentNode)
          .classed("active", true)
          .datum()
        currentColor = d3.select(@parentNode).attr("data-color")

        # if the clicked show-me isn't in view, then transition scrollTop
        offsetTop = @parentNode.offsetTop + @offsetTop
        if offsetTop < document.body.scrollTop or offsetTop > document.body.scrollTop + window.innerHeight or currentChapter isnt lastChapter
          d3.select(window).transition().tween "scrollTop", =>
            state.transitioningScrollTop = true
            i = d3.interpolate document.body.scrollTop, @parentNode.offsetTop
            (t) -> document.body.scrollTop = i(t)
          .each "end", ->
            state.transitioningScrollTop = false


    # header
    d3.select(".visualization .header h2").text props.heading

    legendSel = d3.select(".visualization .header .legend").selectAll(".color")
    if not legendSel.empty()
      legendSel.remove()

    # legend
    sel = d3.select(".visualization .header .legend")
      .classed "timeline", props.type is "timeline"
      .selectAll(".color")
      .data(props.colors ? [])
    sel.enter().append("div").attr("class", "color")
      .each ->
        d3.select(@).append("div").attr("class", "values")
        d3.select(@).append("div").attr("class", "label")
    value_sel = sel.select(".values").selectAll(".value")
      .data((d) -> [].concat d.value)
    value_sel.enter().append("div").attr("class", "value")
    value_sel.style("background-color", String)
    value_sel.exit().remove()
    label_sel = sel.select(".label").text((d) -> d.label)
    sel.exit().remove()

    constructLegend = () ->
      colors = map.getColorsForEthnicity(state.ethnicity)

      legendSel = d3.select(".visualization .header .legend").selectAll(".color")
        .data(colors)
      legendSel.enter().append("div").attr("class", "color")
        .each (d, i) ->
          d3.select(@).append("div").attr("class", "values")
          # d3.select(@).append("div").attr("class", "value")
          #   .style
          #     "background-color": d.value
          #     "opacity": d.alpha
          d3.select(@).append("div").attr("class", "label")
            .text(d.label)
      value_sel = legendSel.select(".values").selectAll(".value")
        .data((d) -> [].concat d.value)
      value_sel.enter().append("div").attr("class", "value")
      legendSel
        .each (d, i) ->
            d3.select(@).select("div.value")
              .style
                "background-color": d.value
                "opacity": d.alpha
            d3.select(@).select("div.label")
              .text(d.label)

    #dropdown
    sel = d3.select(".dropdown")
    if props.mode is "ethnicity"
      console.log "ethnicity", sel.empty()
      if sel.empty()
        d3.select(".header").append("div")
          .attr "class" : "dropdownLabel"
          .text "Please select"
        sel = d3.select(".visualization .header").append("div")
          .classed("dropdown", true)
        constructLegend()
    else
      sel.remove()
      d3.select(".header").select("div.dropdownLabel").remove()

    sel.call dropdown().on "select", (d) =>
      state.ethnicity = d
      map.call d3.select(".chart"), {ethnicity: state.ethnicity, split: false, mode: "ethnicity"}

      constructLegend()

    # nav
    currNav = props.url.match(/\/([^\/]+)\//)[1]
    if currNav isnt prevNav
      d3.select(".nav")
        .selectAll("g")
        .classed("current", false)
        .data [currNav], String
        .classed("current", true)
        .select(".visible")
          .attr "r", 8
        .transition().duration(600).ease("cubic-out")
          .attr "r", 4
      prevNav = currNav

    # chart
    container_sel = d3.select(".chart-container")
    size = [container_sel.property("offsetWidth"), container_sel.property("offsetHeight")]
    switch props.type
      when "map"
        map.call d3.select(".chart"), { size, ethnicity: state.ethnicity, split: props.split, mode: props.mode}
      when "bar-chart"
        barChart.call d3.select(".chart"), _.extend { size }, _.pick props, "bars", "rows", "data", "label", "colors"
      when "timeline"
        timeline.call d3.select(".chart"), _.extend { size }, _.pick props, "lines", "data", "label", "colors"
      when "pies"
        pies
          .on "hover", (ethnicity) ->
            state.hoverEthnicity = ethnicity
            render props
          .call d3.select(".chart"),
            _.extend ethnicity: state.hoverEthnicity,
              { size }
              _.pick props, "pies", "slices", "outer-slices", "data", "colors"
      # else
      #   d3.select(".chart").selectAll("*").remove()


  d3.select(window)
    .on "hashchange", ->
      route @location.hash.slice(1)
    .on "scroll", ->
      currentChapter = null
      d3.select(".story")
        .selectAll(".chapter")
        .classed("current", false)
        .each(->
          if @offsetTop <= document.body.scrollTop
            currentChapter = d3.select(@).datum()
        )
        .data [currentChapter], String
        .classed("current", true)

      if not state.transitioningScrollTop
        scrollTop = @document.body.scrollTop
        current = d3.selectAll(".show-me")
          .filter(-> d3.select(@).classed("current")).node()
        if current?
          offsetTop = current.parentNode.offsetTop + current.offsetTop
          if offsetTop < scrollTop or offsetTop > scrollTop + window.innerHeight
            s = d3.selectAll(".show-me").filter ->
              @parentNode.offsetTop + @offsetTop > scrollTop
            # window.location.hash = s.node().attributes.href.value.slice(1)
            route s.node().attributes.href.value.slice(1)

  chapters = d3.selectAll(".chapter")
    .datum ->
      d3.select(@).attr("class")
        .replace("chapter", "").replace("current", "").trim()
    .attr "data-color", (d, i) -> colors[i+5]

  nav = d3.select(".nav")
    .attr("width", 25)
    .style("width", 25)
    .attr("height", 21 * chapters.size())
    .style("height", 21 * chapters.size())

  chapters.select("a").on "click", ->
    if not d3.event.metaKey and not d3.event.shiftKey
      route @attributes.href.value.slice(1)
      d3.event.preventDefault()

  chapters.each (chapter, i) ->
    element = nav.append("g")
      .datum chapter
      .attr "transform", "translate(15, #{ 7 + i*21 })"
      .on "click", (d) ->
        route "/#{d}"
    element.append("circle")
      .style "fill", "transparent"
      .attr "r", 8
    element.append("circle").classed("visible", true)
      .style "fill", d3.select(@).attr("data-color")
      .attr "r", 4

    d3.select(@).select("a").attr "href", "#/#{chapter}"
    d3.select(@).selectAll(".show-me")
        .attr "href", (d, i) -> "#/#{chapter}/#{i+1}"
        .on "click", ->
          if not d3.event.metaKey and not d3.event.shiftKey
            route @attributes.href.value.slice(1)
            d3.event.preventDefault()


  currentChapter = null
  d3.select(".story")
    .selectAll(".chapter")
    .classed("current", false)
    .each(->
      if @offsetTop <= document.body.scrollTop
        currentChapter = d3.select(@).datum()
    )
    .data [currentChapter], String
    .classed("current", true)
  route @location.hash.slice(1)

  window.onresize = () => render(currentProps)

