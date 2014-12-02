define ["d3", "topojson"], (d3, topojson) ->

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
    "Hawai":{
      SO: 1991
      SOGI:  2011
    }
    "Illinoi":{
      SO: 2005
      SOGI:  2005
    }
    "Iow":{
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
    "New Jersey ":{
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

  map =  () ->
    g = @.selectAll("g").data([null]).enter().append("g").attr "id" : "vectorMap"

    map_path = g.selectAll("path")
      .data(geometries)

    map_path.enter()
      .append("path")
      .attr
        "d" : path
        "class" : (d) ->
          if not data[index[d.id]]? then return "no"
          if data[index[d.id]].SOGI then return "sogi"
          if data[index[d.id]].SO then return "so"
        "id" : (d) -> d.id




  map