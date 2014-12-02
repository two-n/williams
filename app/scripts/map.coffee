define ["d3", "topojson"], (d3, topojson) ->

  vectorMap = null
  featureSet = null
  geometries = null
  d3.json("./assets/map.topo.json", (err, _vectorMap) =>
    vectorMap = _vectorMap
    featureSet = topojson.feature(vectorMap, vectorMap.objects.usa)
    geometries = featureSet.features
  )

  projection = d3.geo.albersUsa()
  path = d3.geo.path()
    .projection(projection)

  map =  () ->
    g = @.selectAll("g").data([null]).enter().append("g").attr "id" : "vectorMap"

    map_path = g.selectAll("path")
      .data(geometries)

    map_path.enter()
      .append("path")
      .attr
        "d" : path
        "id" : (d) -> d.id

  map