require.config
  paths:
    "d3": "vendor/d3/d3.min"
    "topojson": "vendor/topojson/topojson"
    "underscore": "vendor/underscore/underscore"


define ["d3", "underscore", "./graphics", "./map", "./dropdown", "./bar-chart", "./timeline"], (d3, _, graphics, map, dropdown, barChart, timeline) ->

  colors = ["#EDEDEE", "#D1D1D4", "#A6A6AC", "#797980", "#38383C", "#FF0055", "#FF9C00", "#FFDF00", "#00C775", "#0075CA", "#9843A0"]
  currentProps = null

  state =
    transitioningScrollTop: false
    path: null
    ethnicity: "black"

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

    # legend
    sel = d3.select(".visualization .header .legend").selectAll(".color")
      .data(props.colors ? [])
    sel.enter().append("div").attr("class", "color")
      .each (d, i) ->
        d3.select(@).append("div").attr("class", "value")
        d3.select(@).append("div").attr("class", "label")
    sel.select(".value").style("background-color", (d) -> d.value)
    sel.select(".label").text((d) -> d.label)
    sel.exit().remove()

    constructLegend = () ->
      colors = map.getColorsForEthnicity(state.ethnicity)

      legendSel = d3.select(".visualization .header .legend").selectAll(".color")
        .data(colors)
      legendSel.enter().append("div").attr("class", "color")
        .each (d, i) ->
          d3.select(@).append("div").attr("class", "value")
            .style 
              "background-color": d.value
              "opacity": d.alpha
          d3.select(@).append("div").attr("class", "label")
            .text(d.label)
      legendSel
        .each (d, i) ->
            d3.select(@).select("div.value")
              .style 
                "background-color": d.value
                "opacity": d.alpha
            d3.select(@).select("div.label")
              .text(d.label)

      legendSel.exit().remove()

    #dropdown
    sel = d3.select(".visualization .header .dropdown")
    if props.mode is "ethnicity"
      if sel.empty()
        sel = d3.select(".visualization .header").append("div")
          .classed("dropdown", true)
        constructLegend()
    else
      sel.remove()

    sel.call dropdown().on "select", (d) =>
      state.ethnicity = d
      map.call d3.select(".chart"), {ethnicity: state.ethnicity, split: false, mode: "ethnicity"}

      constructLegend()

    # nav
    d3.select(".nav")
      .selectAll("g")
      .classed("current", false)
      .data [props.url.match(/\/([^\/]+)\//)[1]], String
      .classed("current", true)
      .select(".visible")
        .attr "r", 8
      .transition().duration(600).ease("cubic-out")
        .attr "r", 4

    # chart
    # props.color = currentColor
    switch props.type
      when "map"
        map.call d3.select(".chart"), {ethnicity: state.ethnicity, split: props.split, mode: props.mode}
      when "bar-chart"
        barChart.call d3.select(".chart"), _.pick props, "bars", "rows", "data", "label", "colors"
      when "timeline"
        timeline.call d3.select(".chart"), _.pick props, "lines", "data", "label", "colors"
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

