define ["d3"], (d3) -> ->

  options = [
    {
      dataId: "latino"
      label: "Latino"
    },
    {
      dataId: "white"
      label: "White"
    },
    {
      dataId: "black"
      label: "African-American"
    },
    {
      dataId: "indian"
      label: "American Indian-Alaskan Native"
    },
    {
      dataId: "asian"
      label: "Asian"
    },
    {
      dataId: "pacislander"
      label: "Native Hawaiian-Pacific Islander"
    },
    {
      dataId: "other"
      label: "Other"
    },
    {
      dataId: "multi"
      label: "Multiracial"
    },
    {
      dataId: "asianpac"
      label: "Asian/Pac-Islander"
    }
  ]
  collapsed = true
  active = 2

  dispatch = d3.dispatch("select")

  dropdown = () ->
    @.on "mouseenter", () =>
      collapsed = false
      dropdown.call @
    @.on "mouseleave", () =>
      collapsed = true
      dropdown.call @

    @.classed("collapsed", collapsed)

    ul = @.selectAll("ul")
    if ul.empty()
      ul = @.append("ul")

    items = @.selectAll("li").data(options)
    items.enter()
      .append("li")
        .attr
          "class": "item"
        .text (d) -> d.label
      .on "click", (d,i) =>
        active = i
        collapsed = true
        dispatch.select d.dataId
        dropdown.call @
    items.classed("active", (d,i) -> i is active)

  d3.rebind dropdown, dispatch, "on"
