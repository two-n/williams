define ["d3", "underscore", "./map"], (d3, _, map) ->
  cover = (props) ->
    map.call @,
      size: props.size
      split: true
      mode: "silhouette"
      fill: "dark"
      scaling: "cover"


    hook = """
      While the nation seems on the verge of full marriage
      equality, most states still have not adopted
      non-discrimination laws protecting LGBT people.

      This interactive explores the increased disparities that
      LGBT people face who live in the states without state
      sexual orientation non-discrimination laws.  More than
      60% of LGBT Americans live in the South, Midwest and
      Mountain states, where they face a more challenging
      social climate and legal landscape and have greater dispar-
      ities when compared to non-LGBT people across a number
      of economic and health indicators.

      Please click on the visuals in this interactive to explore
      more of the data.
    """
    hook_sel = @select(".hook")
    if hook_sel.empty()
      hook_sel = @append("text").attr("class", "hook")
    hook_sel.attr("transform", "translate(300, 187)")
    tspan_sel = hook_sel.selectAll("tspan").data hook.split("\n")
    tspan_sel.enter().append("tspan")
        .attr("x", 0)
        .attr("dy", 19)
    tspan_sel.text (d) -> if d then d else " "
    tspan_sel.exit().remove()

  cover.deps = ["#vectorMap", ".hook"]

  return cover
