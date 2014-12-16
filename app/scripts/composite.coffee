define ["d3", "underscore", "./clean", "./map", "./bar-chart"], (d3, _, clean, map, barChart) ->
  (props) ->
    clean.call @, ["#vectorMap"], =>
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
        ethnicity: "black"
        split: true
        mode: "bubble"
        percentageByRegion: percentageByRegion
        bubbleColor: props.colors[0].value
        solidCircle: "LGBT"
        dashedCircle: "Non-LGBT"

