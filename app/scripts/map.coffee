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
    "01":  { postal: "AL" , fullName: "Alabama"}
    "02":  { postal: "AK" , fullName: "Alaska"}
    "04":  { postal: "AZ" , fullName: "Arizona"}
    "05":  { postal: "AR" , fullName: "Arkansas"}
    "06":  { postal: "CA" , fullName: "California"}
    "08":  { postal: "CO" , fullName: "Colorado"}
    "09":  { postal: "CT" , fullName: "Connecticut"}
    "10":  { postal: "DE" , fullName: "Delaware"}
    "11":  { postal: "DC" , fullName: "Washington DC"}
    "12":  { postal: "FL" , fullName: "Florida"}
    "13":  { postal: "GA" , fullName: "Georgia"}
    "15":  { postal: "HI" , fullName: "Hawaii"}
    "16":  { postal: "ID" , fullName: "Idaho"}
    "17":  { postal: "IL" , fullName: "Illinois"}
    "18":  { postal: "IN" , fullName: "Indiana"}
    "19":  { postal: "IA" , fullName: "Iowa"}
    "20":  { postal: "KS" , fullName: "Kansas"}
    "21":  { postal: "KY" , fullName: "Kentucky"}
    "22":  { postal: "LA" , fullName: "Louisiana"}
    "23":  { postal: "ME" , fullName: "Maine"}
    "24":  { postal: "MD" , fullName: "Maryland"}
    "25":  { postal: "MA" , fullName: "Massachusetts"}
    "26":  { postal: "MI" , fullName: "Michigan"}
    "27":  { postal: "MN" , fullName: "Minnesota"}
    "28":  { postal: "MS" , fullName: "Mississippi"}
    "29":  { postal: "MO" , fullName: "Missouri"}
    "30":  { postal: "MT" , fullName: "Montana"}
    "31":  { postal: "NE" , fullName: "Nebraska"}
    "32":  { postal: "NV" , fullName: "Nevada"}
    "33":  { postal: "NH" , fullName: "New Hampshire"}
    "34":  { postal: "NJ" , fullName: "New Jersey"}
    "35":  { postal: "NM" , fullName: "New Mexico"}
    "36":  { postal: "NY" , fullName: "New York"}
    "37":  { postal: "NC" , fullName: "North Carolina"}
    "38":  { postal: "ND" , fullName: "North Dakota"}
    "39":  { postal: "OH" , fullName: "Ohio"}
    "40":  { postal: "OK" , fullName: "Oklahoma"}
    "41":  { postal: "OR" , fullName: "Oregon"}
    "42":  { postal: "PA" , fullName: "Pennsylvania"}
    "44":  { postal: "RI" , fullName: "Rhode Island"}
    "45":  { postal: "SC" , fullName: "South Carolina"}
    "46":  { postal: "SD" , fullName: "South Dakota"}
    "47":  { postal: "TN" , fullName: "Tennessee"}
    "48":  { postal: "TX" , fullName: "Texas"}
    "49":  { postal: "UT" , fullName: "Utah"}
    "50":  { postal: "VT" , fullName: "Vermont"}
    "51":  { postal: "VA" , fullName: "Virginia"}
    "53":  { postal: "WA" , fullName: "Washington"}
    "54":  { postal: "WV" , fullName: "West Virginia"}
    "55":  { postal: "WI" , fullName: "Wisconsin"}
    "56":  { postal: "WY" , fullName: "Wyoming"}
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
  stateGeometries = null
  d3.json("./assets/counties.topo.json", (err, _vectorMap) =>
    vectorMap = _vectorMap
    stateGeometries = topojson.feature(vectorMap, vectorMap.objects.states).features
  )

  path = d3.geo.path()
    .projection(null)

  map =  (split) ->
    g = @.selectAll("g").data([null])
    g.enter().append("g").attr "id" : "vectorMap"
    regions = g.selectAll(".region").data(_.keys(regionByName))
    regions.enter().append("g").attr
      "class": "region"
      "id": (d) -> d
    .selectAll("path").data((d) -> stateGeometries.filter (state) -> _.contains regionByName[d].states, index[state.id]?.fullName).enter()
      .append("path")
      .attr
        "d" : path
        "class" : (d) ->
          if not data[index[d.id].fullName]? then return "no"
          if data[index[d.id].fullName].SOGI then return "sogi"
          if data[index[d.id].fullName].SO then return "so"
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