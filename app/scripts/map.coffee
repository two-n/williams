define ["d3", "topojson"], (d3, topojson) ->
  regionByName = {
    "Pacific": {
      states: ["Alaska", "California", "Hawaii", "Oregon", "Washington"]
      centroid: [-123,39]
      offset: [-39.48530542559064, -15.370925469394933]
      value: 39250000
    }
    "Mountain": {
      states: ["Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico", "Utah", "Wyoming"]
      centroid: [-111,40]
      offset: [-7.987967225259922, 1.193425583016392]
      value: 17160000
    }
    "Midwest": {
      states: ["Illinois", "Indiana", "Iowa", "Kansas", "Michigan", "Minnesota", "Missouri", "Nebraska", "North Dakota", "Ohio", "South Dakota", "Wisconsin"]
      centroid: [-92,43]
      offset: [17.14660810580267, -5.690153784351679]
      value: 51810000
    }
    "South": {
      states: ["Alabama", "Arkansas", "Delaware", "Florida", "Georgia", "Kentucky", "Louisiana", "Maryland", "Mississippi", "North Carolina", "Oklahoma", "South Carolina", "Tennessee", "Texas", "Virginia", "District of Columbia", "West Virginia"]
      centroid: [-89,32]
      offset: [16.69364734000476, 20.69134832167154]
      value: 90440000
    }
    "Northeast": {
      states: ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "New Jersey", "New York", "Pennsylvania", "Rhode Island", "Vermont"]
      centroid: [-71,42.5]
      offset: [31.406069531500407, -3.9391785272940893]
      value: 43920000
    }
  };

  index = {
    AL: "Alabama"
    AK: "Alaska"
    AZ: "Arizona"
    AR: "Arkansas"
    CA: "California"
    CO: "Colorado"
    CT: "Connecticut"
    DC: "Washington DC"
    DE: "Delaware"
    FL: "Florida"
    GA: "Georgia"
    HI: "Hawaii"
    ID: "Idaho"
    IL: "Illinois"
    IN: "Indiana"
    IA: "Iowa"
    KS: "Kansas"
    KY: "Kentucky"
    LA: "Louisiana"
    ME: "Maine"
    MD: "Maryland"
    MA: "Massachusetts"
    MI: "Michigan"
    MN: "Minnesota"
    MS: "Mississippi"
    MO: "Missouri"
    MT: "Montana"
    NE: "Nebraska"
    NV: "Nevada"
    NH: "New Hampshire"
    NJ: "New Jersey"
    NM: "New Mexico"
    NY: "New York"
    NC: "North Carolina"
    ND: "North Dakota"
    OH: "Ohio"
    OK: "Oklahoma"
    OR: "Oregon"
    PA: "Pennsylvania"
    RI: "Rhode Island"
    SC: "South Carolina"
    SD: "South Dakota"
    TN: "Tennessee"
    TX: "Texas"
    UT: "Utah"
    VT: "Vermont"
    VA: "Virginia"
    WA: "Washington"
    WV: "West Virginia"
    WI: "Wisconsin"
    WY: "Wyoming"
  }

  data = {
    "California":{
      SO: 1999
      SOGI:  2003
    }
    "Colorado":{
      SO: 2007
      SOGI:  2007
    }
    "Connecticut":{
      SO: 1991
      SOGI:  2011
    }
    "Delawar":{
      SO: 2009
      SOGI:  2013
    }
    "Hawaii":{
      SO: 1991
      SOGI:  2011
    }
    "Illinois":{
      SO: 2005
      SOGI:  2005
    }
    "Iowa":{
      SO: 2007
      SOGI:  2007
    }
    "Maine":{
      SO: 2005
      SOGI:  2005
    }
    "Maryland":{
      SO: 2001
      SOGI:  2014
    }
    "Massachusetts":{
      SO: 1989
      SOGI:  2011
    }
    "Minnesota":{
      SO: 1993
      SOGI:  1993
    }
    "Nevada":{
      SO: 1999
      SOGI:  2011
    }
    "New Hampshire":{
      SO: 1997
      SOGI:  null
    }
    "New Mexico":{
      SO: 2003
      SOGI:  2003
    }
    "New York":{
      SO: 2002
      SOGI:  null
    }
    "Oregon":{
      SO: 2007
      SOGI:  2007
    }
    "Rhode Island":{
      SO: 1995
      SOGI:  2001
    }
    "Vermont":{
      SO: 1992
      SOGI:  2007
    }
    "Washington":{
      SO: 2006
      SOGI:  2006
    }
    "Washington DC":{
      SO: 1977
      SOGI:  2005
    }
    "Wisconsin":{
      SO: 1982
      SOGI: null
    }
    "New Jersey":{
       SO: 1991
       SOGI:  2006
    }
  }

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

  map =  (split) ->
    g = @.selectAll("g").data([null])
    g.enter().append("g").attr "id" : "vectorMap"
    regions = g.selectAll(".region").data(_.keys(regionByName))
    regions.enter().append("g").attr
      "class": "region"
      "id": (d) -> d
    .selectAll("path").data((d) -> geometries.filter (state) -> _.contains regionByName[d].states, index[state.id]).enter()
      .append("path")
      .attr
        "d" : path
        "class" : (d) ->
          if not data[index[d.id]]? then return "no"
          if data[index[d.id]].SOGI then return "sogi"
          if data[index[d.id]].SO then return "so"
        "id" : (d) -> d.id

    g.selectAll(".region")
      .transition()
      .delay((d,i) -> 250*(5-i))
      .duration(1000)
      .attr("transform", (d) =>
        if split
          x = regionByName[d].offset[0]
          y = regionByName[d].offset[1]
          "translate(#{x},#{y})"
        else
          "translate(0,0)"
      )
  map