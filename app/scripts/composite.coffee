define ["d3", "underscore", "./map", "./bar-chart"], (d3, _, map, barChart) ->
  composite = (props) ->
    size = props.size

    index = _.indexBy d3.csv.parse(props.data), ""
    percentageByRegion = _.pick(index, "Pacific", "Mountain", "Midwest", "South", "Northeast")

    # barChart.call d3.select(".chart"),
    #   _.extend { size },
    #     rows: props.rows ? ["21 Protective States", "29 Non-Protective States"]
    #     bars: props.bars ? ["LGBT", "Non-LGBT"]
    #     _.pick props, "data", "label", "colors"

    map.call d3.select(".chart"),
      size: size
      split: true
      mode: "bubble"
      percentageByRegion: percentageByRegion
      bubbleColor: props.colors[0].value
      solidCircle: "LGBT"
      dashedCircle: "Non-LGBT"

  composite.deps = ["#vectorMap", ".unscaledRegionOverlay"]

  return composite
