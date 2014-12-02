require.config
  paths:
    "d3": "vendor/d3/d3.min"
    "topojson": "vendor/topojson/topojson"
    "underscore": "vendor/underscore/underscore"
    'topojson': '../vendor/topojson/topojson'

define ["d3", "underscore", "./graphics", "./map"], (d3, _, graphics, map) ->

  state =
    transitioningScrollTop: false

  route = (path) ->
    path or= "/introduction/1"
    render _.findWhere graphics, url: path

  render = (props) ->
    if not props? then return

    # story
    d3.select(".story")
      .selectAll(".show-me")
      .classed("current", false)
      .filter ->
        d3.select(@).attr("href").slice(1) is props.url
      .classed("current", true)
      .each ->
        # if the clicked show-me isn't in view, then transition scrollTop
        if @offsetTop < document.body.scrollTop or @offsetTop > document.body.scrollTop + window.innerHeight
          d3.select(window).transition().tween "scrollTop", =>
            state.transitioningScrollTop = true
            i = d3.interpolate document.body.scrollTop, @parentNode.offsetTop
            # i = d3.interpolate @parentNode.offsetTop, @parentNode.offsetTop
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
          .style("background-color", d.value)
        d3.select(@).append("div").attr("class", "label")
          .text(d.label)
    sel.exit().remove()

    # nav
    d3.select(".nav")
      .selectAll("circle")
      .classed("current", false)
      .data [props.url.match(/\/([^\/]+)\//)[1]], String
      .classed("current", true)
      .attr "r", 8
      .transition()
      .duration(600)
      .ease("cubic-out")
      .attr "r", 4


    map.call d3.select(".chart")


  d3.select(window)
    .on "load", ->
      route @location.hash.slice(1)
    .on "hashchange", ->
      route @location.hash.slice(1)
    .on "scroll", ->
      if state.transitioningScrollTop then return
      scrollTop = @document.body.scrollTop
      current = d3.selectAll(".show-me")
        .filter(-> d3.select(@).classed("current")).node()
      if (current.offsetTop < scrollTop) or (current.offsetTop > scrollTop + window.innerHeight)
        s = d3.selectAll(".show-me").filter ->
          @offsetTop > scrollTop
        window.location.hash = s.node().attributes.href.value.slice(1)

  chapters = d3.selectAll(".chapter")
  nav = d3.select(".nav")
    .attr("width", 25)
    .style("width", 25)
    .attr("height", 21 * chapters.size())
    .style("height", 21 * chapters.size())
  chapters.each (d, i) ->
    chapter = d3.select(@).attr("class")
      .replace("chapter", "").replace("current", "").trim()

    nav.append("circle")
      .datum chapter
      .style "fill", d3.select(@).select("h1").style("color")
      .attr "r", 4
      .attr "cx", 15
      .attr "cy", 7 + i*21
      .on "click", (d) ->
        window.location.hash = "/#{d}/1"

    d3.select(@).selectAll(".show-me")
      .attr "href", (d, i) -> "#/#{chapter}/#{i+1}"
      .on "focus", ->
        window.location.hash = @attributes.href.value.slice(1)
      # .on "click", ->
        # if not d3.event.metaKey and not d3.event.shiftKey
        # route @attributes.href.value.slice(1)
          # d3.event.preventDefault()
