define ["d3", "underscore", "./map"], (d3, _, map) ->
  cover = (props) ->
    map.call @,
      size: props.size
      split: true
      mode: "silhouette"
      fill: "dark"
      scaling: "cover"

  cover.deps = ["#vectorMap"]

  return cover
