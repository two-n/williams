require.config
  paths:
    "d3": "vendor/d3/d3.min"
    "topojson": "vendor/topojson/topojson"
    "underscore": "vendor/underscore/underscore"
    "hammer": "vendor/hammerjs/hammer.min"


define ["d3", "underscore", "hammer", "./graphics", "./map", "./dropdown", "./bar-chart", "./timeline", "./pies", "./conclusion", "./cover"], (d3, _, Hammer, graphics, map, dropdown, barChart, timeline, pies, conclusion, cover) ->
  # colors = ["#EDEDEE", "#D1D1D4", "#A6A6AC", "#797980", "#38383C", "#FF0055", "#FF9C00", "#FFDF00", "#00C775", "#0075CA", "#9843A0"]
  colors = ["#EDEDEE", "#D1D1D4", "#A6A6AC", "#797980", "#38383C", "#FF0055", "#FF9C00", "#ECD000", "#00C775", "#0075CA", "#9843A0"]
  currentProps = null

  state =
    transitioningScrollTop: false
    path: null
    ethnicity: "black"

  prevChapter = null


  d3.selectAll(".cover.chapter, .conclusion.chapter")
    .style "height", window.innerHeight - 80 - 30 + "px"


  route = (path) ->
    if state.path is path then return
    state.path = path

    # TODO see http://stackoverflow.com/a/23924886 -- test iOS Chrome
    window.location.replace("#" + path)

    path or= "/cover"
    if not ~path.slice(1).indexOf("\/")
      path += "/1"
    render _.findWhere graphics, url: path

  render = (props) ->
    if not props? then return
    currentProps = props

    currentChapter = props.url.match(/\/([^\/]+)\//)[1]

    # story
    story_sel = d3.select(".story")
    chapter_sel = story_sel.selectAll(".chapter")

    lastChapter = null
    chapter_sel.each ->
      if @offsetTop <= window.pageYOffset
        lastChapter = d3.select(@).datum()
    chapter_sel.filter((d) -> d isnt currentChapter).classed("active", false)
    activeIndex = -1
    active = chapter_sel
      .filter (d, i) ->
        condition = d is currentChapter
        if condition then activeIndex = i
        return condition
      .classed("active", true)
    currentColor = active.attr("data-color")
    if prevChapter isnt currentChapter
      d3.select(window).transition()
        .tween "scrollTop", =>
          state.transitioningScrollTop = true
          i = d3.interpolate window.pageYOffset, active.node().offsetTop
          (t) -> window.scrollTo 0, i(t)
        .each "end", ->
          state.transitioningScrollTop = false

    # story_sel.selectAll(".show-me")
    #   .classed("current", false)
    #   .filter ->
    #     d3.select(@).attr("href").slice(1) is props.url
    #   .classed("current", true)
    #   .each ->
    #     # if the clicked show-me isn't in view, then transition scrollTop
    #     offsetTop = @parentNode.offsetTop + @offsetTop
    #     if offsetTop < window.pageYOffset or offsetTop > window.pageYOffset + window.innerHeight or currentChapter isnt lastChapter
    #       d3.select(window).transition().tween "scrollTop", =>
    #         state.transitioningScrollTop = true
    #         i = d3.interpolate window.pageYOffset, @parentNode.offsetTop
    #         (t) -> window.scrollTo 0, i(t)
    #       .each "end", ->
    #         state.transitioningScrollTop = false

    showme_sel = story_sel.selectAll(".show-me")
      .classed "current", -> d3.select(@).attr("href").slice(1) is props.url

    arrow_sel = story_sel.select(".arrow")
    if chapter_sel.size() - 1 is activeIndex
      arrow_sel.remove()
    else if arrow_sel.empty()
      arrow_sel = story_sel.append("div").attr("class", "arrow")
      arrow_sel
        .append("svg")
          .attr("width", 80)
          .attr("height", 25)
        .append("path")
          .attr("transform", "translate(40, 0)")
          .attr("d", "M -34 0 L 0 21 L 34 0")

    arrow_sel.on "click", ->
      chapters = story_sel.selectAll(".chapter").data()
      nextChapter = chapters[chapters.indexOf(currentChapter) + 1]
      route "/#{nextChapter}"

    arrow_sel.select("path").transition().duration(450)
      .attr("stroke", currentColor)

    # header
    heading_sel = d3.select(".visualization .header h2")
      .classed "cover", currentChapter is "cover"
      .selectAll(".line").data (props.heading ? "").split("\n")
    heading_sel.enter().append("div").classed("line", true)
    heading_sel.text (d) -> d or " "
    heading_sel.exit().remove()

    # legendSel = d3.select(".visualization .header .legend").selectAll(".color")
    # if not legendSel.empty()
    #   legendSel.remove()

    # legend
    sel = d3.select(".visualization .header .legend")
      .attr "class", "legend #{ props.type }"
      .selectAll(".color")
      .data(props.colors ? [], (d) -> d.label)
    sel.enter().append("div").attr("class", "color")
      .each ->
        d3.select(@).append("div").attr("class", "values")
        d3.select(@).append("div").attr("class", "label")
    value_sel = sel.select(".values").selectAll(".value")
      .data((d) -> [].concat d.value)
    value_sel.enter()
      .append("div").attr("class", "value")
      .style("background-color", String)
    value_sel.transition().duration(600).ease("cubic-out")
      .style("background-color", String)
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


    container_sel = d3.select(".chart-container")
    size = [container_sel.property("offsetWidth"), container_sel.property("offsetHeight")]

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
      container_sel = d3.select(".chart-container")
      size = [container_sel.property("offsetWidth"), container_sel.property("offsetHeight")]

      state.ethnicity = d
      map.call d3.select(".chart"), {size, ethnicity: state.ethnicity, split: false, mode: "ethnicity"}

      constructLegend()

    # nav
    if currentChapter isnt prevChapter
      d3.select(".nav")
        .selectAll("g")
        .classed("current", false)
        .data [currentChapter], String
        .classed("current", true)
        .select(".visible")
          .attr "r", 6
        .transition().duration(600).ease("cubic-out")
          .attr "r", 4

    # chart
    switch props.type
      when "map"
        map.call d3.select(".chart"), { size, ethnicity: state.ethnicity, split: props.split, mode: props.mode}
      when "bar-chart"
        barChart.call d3.select(".chart"), _.extend { size }, _.pick props, "bars", "rows", "data", "label", "colors", "benchmark"
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
      when "conclusion"
        conclusion.call d3.select(".chart"), _.extend { size }, _.pick props, "quote", "attribution"
      when "cover"
        cover.call d3.select(".chart")


    prevChapter = currentChapter


  d3.select(window)
    .on "hashchange", ->
      route @location.hash.slice(1)
    .on "scroll", ->
      topChapter = null
      sel = d3.select(".story").selectAll(".chapter").each ->
        if @offsetTop <= window.pageYOffset then topChapter = d3.select(@).datum()
      sel.filter((d) -> d is topChapter).classed("top", true)
      sel.filter((d) -> d isnt topChapter).classed("top", false)

      # if not state.transitioningScrollTop
      #   scrollTop = @pageYOffset
      #   current = d3.selectAll(".show-me")
      #     .filter(-> d3.select(@).classed("current")).node()
      #   if current?
      #     offsetTop = current.parentNode.offsetTop + current.offsetTop
      #     if offsetTop < scrollTop or offsetTop > scrollTop + window.innerHeight
      #       s = d3.selectAll(".show-me").filter ->
      #         @parentNode.offsetTop + @offsetTop > scrollTop
      #       route s.node().attributes.href.value.slice(1)
      if not state.transitioningScrollTop
        scrollTop = @pageYOffset
        # d3.select(".story")
        #   .selectAll(".chapter")
        #   .data [currentChapter], String
        #   .each ->
        #     offsetTop = @parentNode.offsetTop + @offsetTop
        #     if offsetTop < scrollTop or offsetTop > scrollTop + window.innerHeight
        #       s = d3.selectAll(".chapter").filter ->
        #         @parentNode.offsetTop + @offsetTop > scrollTop
        #       route s.select("h1 a").node().attributes.href.value.slice(1)


  chapters = d3.selectAll(".chapter")
    .datum ->
      d3.select(@).attr("class")
        .replace(/chapter|top|current/g, "").trim()
    .attr "data-color", (d, i) -> [].concat(colors[9], colors[5...])[i]

  nav_separation = 21
  nav = d3.select(".nav")
    .attr("width", 25)
    .style("width", 25)
    .attr("height", nav_separation * chapters.size())
    .style("height", nav_separation * chapters.size())
    .style("margin-top", -nav_separation * chapters.size() / 2 + "px")

  chapters.select("a").on "click", ->
    if not d3.event.metaKey and not d3.event.shiftKey
      route @attributes.href.value.slice(1)
      d3.event.preventDefault()

  chapters.each (chapter, i) ->
    element = nav.append("g")
      .datum chapter
      .attr "transform", "translate(15, #{ 7 + i*nav_separation })"
      .on "click", (d) -> route "/#{d}"
      .each (d) ->
        Hammer(@, {preventDefault: true}).on "tap", => route "/#{d}"
    element.append("circle")
      .style "fill", "transparent"
      .attr "r", 8
    element.append("circle").classed("visible", true)
      .style "fill", d3.select(@).attr("data-color")
      .attr "r", 4

    d3.select(@).select("h1 a").attr "href", "#/#{chapter}"
    d3.select(@).selectAll(".show-me")
      .attr "href", (d, i) -> "#/#{chapter}/#{i+1}"
      .on "click", ->
        if not d3.event.metaKey and not d3.event.shiftKey
          route @attributes.href.value.slice(1)
          d3.event.preventDefault()
      .each ->
        Hammer(@, {preventDefault: true}).on "tap", =>
          route @attributes.href.value.slice(1)


  currentChapter = null
  d3.select(".story")
    .selectAll(".chapter")
    .classed("top", false)
    .each(->
      if @offsetTop <= window.pageYOffset
        currentChapter = d3.select(@).datum()
    )
    .data [currentChapter], String
    .classed("top", true)

  route @location.hash.slice(1)

  window.onresize = () => render(currentProps)

