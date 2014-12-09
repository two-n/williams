define ["d3", "topojson", "./callout", "./clean", "../assets/counties.topo.json", "../assets/census_data.json"], (d3, topojson, callout, clean, _vectorMap, data) ->

  vectorMap = _vectorMap
  countyGeometries = topojson.feature(vectorMap, vectorMap.objects.counties).features
  stateGeometries = topojson.feature(vectorMap, vectorMap.objects.states).features
  path = d3.geo.path().projection(null)
  scale = 1

  projection = d3.geo.albersUsa().scale(1280).translate([960/2,600/2])

  # data = null
  # d3.csv("./assets/census_race.csv",
  #   (d,i) ->
  #     {
  #       id: +d.stcounty
  #       countyName: d["countyname"]
  #       latino: +d["%hisptot"]
  #       white: +d["%whtot"]
  #       black: +d["%afamtot"]
  #       # asian: +d["%asiantot"]
  #       indian: +d["%aiantot"]
  #       # pacislander: +d["%nhpitot"]
  #       # other: +d["%othtot"]
  #       # multi: +d["%mracetot"]
  #       asianpac: +d["%API"]
  #     }
  #   ,(err, _data) => 
  #     data = _data
  #     console.log JSON.stringify(data)

  #   )

  myScale = {
    latino: d3.scale.threshold()
      .domain([0,0.01,0.2,0.4,0.6,0.8,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
    black: d3.scale.threshold()
      .domain([0,0.01,0.2,0.4,0.6,0.8,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
    white: d3.scale.threshold()
      .domain([0,0.01,0.2,0.4,0.6,0.8,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
    # asian: d3.scale.threshold()
    #   .domain([0,0.01,0.2,0.4,0.6,0.8,1])
    #   .range([0,0,0.1,0.4,0.6,0.8,1])
    indian: d3.scale.threshold()
      .domain([0,0.01,0.2,0.4,0.6,0.8,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
    # pacislander: d3.scale.threshold()
    #   .domain([0,0.01,0.2,0.4,0.6,0.8,1])
    #   .range([0,0,0.1,0.4,0.6,0.8,1])
    # other: d3.scale.threshold()
    #   .domain([0,0.01,0.2,0.4,0.6,0.8,1])
    #   .range([0,0,0.1,0.4,0.6,0.8,1])
    # multi: d3.scale.threshold()
    #   .domain([0,0.01,0.2,0.4,0.6,0.8,1])
    #   .range([0,0,0.1,0.4,0.6,0.8,1])
    asianpac: d3.scale.threshold()
      .domain([0,0.01,0.2,0.4,0.6,0.8,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
  }
  myScale.white.domain(myScale.white.domain().map((d,i) -> if i > 1 then d*5 else d))
  # myScale.asian.domain(myScale.asian.domain().map((d,i) -> if i > 1 then d*0.1 else d))
  myScale.asianpac.domain(myScale.asianpac.domain().map((d,i) -> if i > 1 then d*0.1 else d))
  # myScale.other.domain(myScale.asianpac.domain().map((d,i) -> if i > 1 then d*0.1 else d))

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
  }

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

  sogiDates = {
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

  bubbleTimeout = null

  modes = {
    protection : {
      stateClass: (d) ->
          if not sogiDates[index[d.id].fullName]? then return "no state"
          if sogiDates[index[d.id].fullName].SOGI then return "sogi state"
          if sogiDates[index[d.id].fullName].SO then return "so state"
      countyClass : "county hidden"
      stroke: null
    }
    bubble : {
      stateClass: "no state"
      countyClass : "county hidden"
      countyMouseEnter : null
      stroke: null
    }
    ethnicity : {
      stateClass: (d) -> "state nofill"
      countyClass : "county"
      stroke: (d) ->
        if sogiDates[index[d.id]?.fullName]? then "white" else "none"
    }
  }

  ethnicities = ["latino", "black", "white", "asianpac", "indian"]
  formatCountyCalloutData = (d, activeEthnicity) ->
    toRet = {}
    toRet.name = d.countyName
    toRet.subSpanText = []
    toRet.subSpanText.push {text: "Latino                            #{d3.format(".2f") d.latino}%", bold: false}
    toRet.subSpanText.push {text: "African-American                  #{d3.format(".2f") d.black}%", bold: false}
    toRet.subSpanText.push {text: "White                             #{d3.format(".2f") d.white}%", bold: false}
    toRet.subSpanText.push {text: "Asian/Pacific Islander            #{d3.format(".2f") d.asianpac}%", bold: false}
    toRet.subSpanText.push {text: "Native American                   #{d3.format(".2f") d.indian}%", bold: false}
    toRet.subSpanText[_.indexOf(ethnicities, activeEthnicity)].bold = true
    [toRet]

  formatStateCalloutData = (d) ->
    toRet = {}
    toRet.name = index[d.id].fullName
    toRet.subSpanText = []
    if sogiDates[index[d.id].fullName]?.SO
      toRet.subSpanText.push {text: "SO Protection Y", bold: "false"}
    if sogiDates[index[d.id].fullName]?.SOGI
      toRet.subSpanText.push {text: "GI Protection Y", bold: "false"}
    [toRet]

  map = (props) ->
    clean.call @, ["#vectorMap"], =>
      size = [@property("offsetWidth"), @property("offsetHeight")]

      ethnicity = props.ethnicity
      split = props.split
      mode = props.mode

      g = @.selectAll("g").data([null])
      g.enter().append("g").attr("id" : "vectorMap")

      padding = 0.03 * size[0]
      size[0] = size[0] - padding - 100
      scale = Math.min size[0]/960, size[1]/600
      g.attr
        transform: "scale(#{scale}) translate(#{padding},0)"

      # county definitions
      countyPaths = g.selectAll("path.county").data(countyGeometries)
      countyPaths.enter()
        .append("path")
        .attr
          "d" : path
          "id" : (d) -> d.id
        .on "mouseleave", (d) =>
          bubbleTimeout = setTimeout((() => callout.call @, path.centroid(d), []), 500)
      countyPaths
        .on "mouseenter", (d) =>
          if bubbleTimeout?
            clearTimeout(bubbleTimeout)
          callout.call g, path.centroid(d), formatCountyCalloutData( _.find(data, (entry) -> entry.id is +d.id ), ethnicity)
        .attr
          "class" : modes[mode].countyClass
          "fill-opacity" : (d) ->
            entry = _.find(data, (entry) -> entry.id is +d.id )
            if entry?
              myScale[ethnicity](entry[ethnicity])
            else
              0

      #state definitions
      g = @.selectAll("g").data([null])
      g.enter().append("g").attr("id" : "vectorMap").attr("transform","translate(100,0)")
      regions = g.selectAll(".region").data(_.keys(regionByName))
      regions.enter().append("g")
        .attr
          "class": "region"
          "id": (d) -> d
      # .append("text")
      #   .attr
      #     "class": "regionLabel"
      #     "x": (d) => projection(regionByName[d].centroid)[0]
      #     "y": (d) => projection(regionByName[d].centroid)[1]
      #   .text((d) -> d)
      regions.selectAll("path").data((d) -> stateGeometries.filter (state) -> _.contains regionByName[d].states, index[state.id]?.fullName).enter()
        .append("path")
        .attr
          "d" : path
          "class" : "state"
      g.selectAll(".state")
        .attr
          "id" : (d) -> d.id
          "class" : modes[mode].stateClass
          "stroke": modes[mode].stroke
          "vector-effect": "non-scaling-stroke"
        .on "mouseenter", (d) =>
          if bubbleTimeout?
            clearTimeout(bubbleTimeout)
          callout.call g, path.centroid(d).map((d) -> d), formatStateCalloutData(d)
        .on "mouseleave", (d) =>
          bubbleTimeout = setTimeout((() => callout.call @, path.centroid(d), []), 500)

      #region definitions
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


      regions.enter()
        .append("text")
          .attr
            "class": "regionLabel"
      regionLabel = d3.selectAll(".regionLabel")
          .attr
            "x": (d) => projection(regionByName[d].centroid)[0]
            "y": (d) => projection(regionByName[d].centroid)[1]
        .text((d) -> d)

      console.log regionLabel

  map.getColorsForEthnicity = (ethnicity) ->
    colorSets = {
      latino : [
        { value: "#ED8F28", label: "0.80 - 1.00", alpha: 1},
        { value: "#ED8F28", label: "0.60 - 0.80", alpha: 0.8 },
        { value: "#ED8F28", label: "0.40 - 0.60", alpha: 0.6 },
        { value: "#ED8F28", label: "0.20 - 0.40", alpha: 0.4 },
        { value: "#ED8F28", label: "0.01 - 0.20", alpha: 0.1 },
      ]
      black : [
        { value: "#ED8F28", label: "0.80 - 1.00", alpha: 1},
        { value: "#ED8F28", label: "0.60 - 0.80", alpha: 0.8 },
        { value: "#ED8F28", label: "0.40 - 0.60", alpha: 0.6 },
        { value: "#ED8F28", label: "0.20 - 0.40", alpha: 0.4 },
        { value: "#ED8F28", label: "0.01 - 0.20", alpha: 0.1 },
      ]
      white : [
        { value: "#ED8F28", label: "4.00 - 5.00", alpha: 1},
        { value: "#ED8F28", label: "3.00 - 4.00", alpha: 0.8 },
        { value: "#ED8F28", label: "2.00 - 3.00", alpha: 0.6 },
        { value: "#ED8F28", label: "1.00 - 2.00", alpha: 0.4 },
        { value: "#ED8F28", label: "0.01 - 1.00", alpha: 0.1 },
      ]
      indian : [
        { value: "#ED8F28", label: "0.80 - 1.00", alpha: 1},
        { value: "#ED8F28", label: "0.60 - 0.80", alpha: 0.8 },
        { value: "#ED8F28", label: "0.40 - 0.60", alpha: 0.6 },
        { value: "#ED8F28", label: "0.20 - 0.40", alpha: 0.4 },
        { value: "#ED8F28", label: "0.01 - 0.20", alpha: 0.1 },
      ]
      asianpac : [
        { value: "#ED8F28", label: "0.08 - 0.1", alpha: 1},
        { value: "#ED8F28", label: "0.06 - 0.08", alpha: 0.8 },
        { value: "#ED8F28", label: "0.40 - 0.60", alpha: 0.6 },
        { value: "#ED8F28", label: "0.20 - 0.40", alpha: 0.4 },
        { value: "#ED8F28", label: "0.01 - 0.20", alpha: 0.1 },
      ]
    }
    return colorSets[ethnicity]

  map
