define ["d3", "underscore", "./map", "./bar-chart"], (d3, _, map, barChart) ->
  composite = (props) ->
    size = props.size

    index = _.indexBy d3.csv.parse(props.data), ""
    percentageByRegion = _.pick(index, "Pacific", "Mountain", "Midwest", "South", "Northeast")

    bars_height = size[1] * 0.3

    map.call d3.select(".chart"),
      size: [size[0], size[1] - bars_height]
      split: true
      mode: "bubble"
      scaling: "composite"
      percentageByRegion: percentageByRegion
      bubbleColor: props.colors[0].value
      solidCircle: "LGBT"
      dashedCircle: "Non-LGBT"
      bubbleTopBound: props.bubbleTopBound

    barChart.call d3.select(".chart"), _.extend {},
      size: [size[0], size[1]]
      margin:
        top: size[1] - bars_height
      rows: props.rows ? ["Protective States", "Non-Protective States"]
      bars: props.bars ? ["LGBT", "Non-LGBT"]
      _.pick props, "data", "label", "colors", "bounds"

  composite.deps = ["#vectorMap", ".unscaledRegionOverlay", ".rows", ".x-axis", ".benchmarks", ".label"]

  return composite
