define ["d3", "topojson", "./callout", "./clean", "../assets/counties.topo.json", "../assets/census_data.json"], (d3, topojson, callout, clean, _vectorMap, data) ->

  vectorMap = _vectorMap
  countyGeometries = topojson.feature(vectorMap, vectorMap.objects.counties).features
  stateGeometries = topojson.feature(vectorMap, vectorMap.objects.states).features
  path = d3.geo.path().projection(null)
  scale = 1

  projection = d3.geo.albersUsa().scale(1280).translate([960/2,600/2])
  circleScale = d3.scale.sqrt().domain([0,100]).range([0,200])

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
      centroid: [-118.5,32.9]
      offset: [-39.48530542559064, -15.370925469394933]
      percentage: 17
      value: 39250000
    }
    "Mountain": {
      states: ["Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico", "Utah", "Wyoming"]
      centroid: [-111,40]
      offset: [-7.987967225259922, 1.193425583016392]
      percentage: 8
      value: 17160000
    }
    "Midwest": {
      states: ["Illinois", "Indiana", "Iowa", "Kansas", "Michigan", "Minnesota", "Missouri", "Nebraska", "North Dakota", "Ohio", "South Dakota", "Wisconsin"]
      centroid: [-92,43]
      offset: [17.14660810580267, -5.690153784351679]
      percentage: 20
      value: 51810000
    }
    "South": {
      states: ["Alabama", "Arkansas", "Delaware", "Florida", "Georgia", "Kentucky", "Louisiana", "Maryland", "Mississippi", "North Carolina", "Oklahoma", "South Carolina", "Tennessee", "Texas", "Virginia", "District of Columbia", "West Virginia"]
      centroid: [-89,32]
      offset: [16.69364734000476, 20.69134832167154]
      percentage: 35
      value: 90440000
    }
    "Northeast": {
      states: ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "New Jersey", "New York", "Pennsylvania", "Rhode Island", "Vermont"]
      centroid: [-71,42.5]
      offset: [31.406069531500407, -3.9391785272940893]
      percentage: 19
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

  isSOProtected = (id) ->
    if not sogiDates[index[id].fullName]? then return false
    if sogiDates[index[id].fullName].SO?
      if sogiDates[index[id].fullName].SO <= currentTime
        return true
    false

  isSOGIProtected = (id) ->
    if not sogiDates[index[id].fullName]? then return false
    if sogiDates[index[id].fullName].SOGI?
      if sogiDates[index[id].fullName].SOGI <= currentTime
        return true
    false

  modes = {
    protection : {
      stateClass: (d) ->
          if not isSOProtected(d.id) then return "no state"
          if isSOGIProtected(d.id) then return "sogi state"
          if isSOProtected(d.id) then return "so state"
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
        if sogiDates[index[d.id]?.fullName]? then "#000" else "none"
    }
  }

  ethnicities = ["latino", "black", "white", "asianpac", "indian"]
  formatCountyCalloutData = (d, activeEthnicity) ->
    toRet = {}
    toRet.name = d.countyName
    toRet.subSpanText = []
    toRet.subSpanText.push {label: "Latino                 ", value: "#{d3.format(".2f") d.latino}%", bold: false}
    toRet.subSpanText.push {label: "African-American       ", value: "#{d3.format(".2f") d.black}%", bold: false}
    toRet.subSpanText.push {label: "White                  ", value: "#{d3.format(".2f") d.white}%", bold: false}
    toRet.subSpanText.push {label: "Asian/Pacific Islander ", value: "#{d3.format(".2f") d.asianpac}%", bold: false}
    toRet.subSpanText.push {label: "Native American        ", value: "#{d3.format(".2f") d.indian}%", bold: false}
    toRet.subSpanText[_.indexOf(ethnicities, activeEthnicity)].bold = true
    [toRet]

  formatStateCalloutData = (d) ->
    toRet = {}
    toRet.name = index[d.id].fullName
    toRet.subSpanText = []
    if sogiDates[index[d.id].fullName]?.SO
      toRet.subSpanText.push {label: "SO Protection", value: "Y", bold: "false", highlightValue: true}
    if sogiDates[index[d.id].fullName]?.SOGI
      toRet.subSpanText.push {label: "GI Protection", value: "Y", bold: "false", highlightValue: true}
    [toRet]


  timeScale = d3.scale.linear()
      .domain([1977, 2014])
      .range([0, 200])
      .clamp(true)
  brush = d3.svg.brush()
      .x(timeScale)
      .extent([0, 0])
  currentTime = 2014

  map = (props) ->
    clean.call @, ["#vectorMap"], =>
      size = [@property("offsetWidth"), @property("offsetHeight")]

      ethnicity = props.ethnicity
      split = props.split
      mode = props.mode

      g = @.selectAll("g").data([null])
      g.enter().append("g").attr("id" : "vectorMap")

      padding = 0.1 * size[0]

      size[0] = size[0] - padding
      scale = Math.min size[0]/960, size[1]/600
      g.attr
        transform: "scale(#{scale}) translate(#{padding*0.5},0)"

      # county definitions
      countyPaths = g.selectAll("path.county").data(countyGeometries)
      countyPaths.enter()
        .append("path")
        .attr
          "d" : path
          "id" : (d) -> d.id
          "fill-opacity": 0
        .on "mouseleave", (d) =>
          bubbleTimeout = setTimeout((() => callout.call @, path.centroid(d), []), 500)
      countyPaths
        .on "mouseenter", (d) =>
          if bubbleTimeout?
            clearTimeout(bubbleTimeout)
          callout.call g, path.centroid(d), formatCountyCalloutData( _.find(data, (entry) -> entry.id is +d.id ), ethnicity)
        .attr
          "class" : modes[mode].countyClass
        .transition().duration(1500).attr
          "fill-opacity" : (d) ->
            entry = _.find(data, (entry) -> entry.id is +d.id )
            if entry?
              myScale[ethnicity](entry[ethnicity])
            else
              0

      stateBackdrop = g.selectAll("path.stateBackdrop").data(stateGeometries)
      stateBackdrop.enter().append("path")
        .attr
          "d" : path
          "class" : "stateBackdrop"
      stateBackdrop
        .attr
          "fill" : "none"
          "stroke" : "#AAA"
          "display" : if mode isnt "ethnicity" then "none" else "inherit"

      #state definitions
      g = @.selectAll("g").data([null])
      g.enter().append("g").attr("id" : "vectorMap").attr("transform","translate(100,0)")
      regions = g.selectAll(".region").data(_.keys(regionByName))
      regions.enter().append("g")
        .attr
          "class": "region"
          "id": (d) -> d
      regions.selectAll("path").data((d) -> stateGeometries.filter (state) -> _.contains regionByName[d].states, index[state.id]?.fullName).enter()
        .append("path")
          .attr
            "d" : path
            "class" : "state"
          .each (d) -> d.parentRegion = @.parentNode
      g.selectAll(".state")
        .attr
          "id" : (d) -> d.id
          "class" : modes[mode].stateClass
          "stroke": modes[mode].stroke
          "vector-effect": "non-scaling-stroke"
        .on "mouseenter", (d) =>
          if mode is "bubble" then return
          if bubbleTimeout?
            clearTimeout(bubbleTimeout)
          adjustedCentroid = path.centroid(d)
          offset = d3.select(d.parentRegion).attr("transform")?.match(/[0-9., -]+/)?[0].split(",") || ["0","0"]
          adjustedCentroid[0] += +offset[0]
          adjustedCentroid[1] += +offset[1]
          callout.call g, adjustedCentroid.map((d) -> d), formatStateCalloutData(d)
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

      regionOverlay = g.selectAll(".regionOverlay")
      if regionOverlay.empty()
        regionOverlay = g.append("g").classed("regionOverlay",true)

      regionBubbleData = []
      if mode is "bubble"
        regionBubbleData = _.keys(regionByName)

      #bubble
      regionBubble = regionOverlay.selectAll(".regionBubble").data(regionBubbleData)
      regionBubble.enter().append("circle")
          .attr
            "class": "regionBubble"
            "r": 0
      regionBubble
        .attr
          "cx": (d) => projection(regionByName[d].centroid)[0]
          "cy": (d) => projection(regionByName[d].centroid)[1]
        .transition().delay((d,i) -> 1000 + 250*(5-i))
          .attr
            "r": (d) => circleScale(regionByName[d].percentage)
      regionBubble.exit().remove()

      #name
      regionLabel = regionOverlay.selectAll(".regionLabel").data(regionBubbleData)
      regionLabel.enter().append("text")
          .attr
            "class": "regionLabel"
            "opacity": 0
      regionLabel
        .attr
          "x": (d) => projection(regionByName[d].centroid)[0]
          "y": (d) => projection(regionByName[d].centroid)[1] + 18
        .text((d) -> d)
        .transition().delay((d,i) -> 1000 + 250*(5-i))
          .attr
            "opacity": 1
      regionLabel.exit().remove()

      #percentage
      regionPercent = regionOverlay.selectAll(".regionPercent").data(regionBubbleData)
      regionPercent.enter().append("text")
          .attr
            "class": "regionPercent"
            "opacity": 0
      regionPercent
        .attr
          "x": (d) => projection(regionByName[d].centroid)[0]
          "y": (d) => projection(regionByName[d].centroid)[1]
        .text((d) => "#{regionByName[d].percentage}\%")
        .transition().delay((d,i) -> 1000 + 250*(5-i))
          .attr
            "opacity": 1
      regionPercent.exit().remove()


      #timescale
      timeAxis = g.select(".timeAxis")
      if timeAxis.empty()
        timeAxis = g.append("g")
            .attr
              "class": "timeAxis"
              "transform": "translate(#{g.node().getBBox().width/2 - 100},#{g.node().getBBox().height * 1.1})"
            .call(d3.svg.axis()
              .scale(timeScale)
              .orient("bottom")
              .tickValues([1977,2014])
              .tickFormat(d3.format(".0f"))
            )
        slider = timeAxis.append("g")
            .attr
              "class": "slider"
              "transform": "translate(-2,-16)"
            .call(brush)
        slider.selectAll(".extent,.resize")
            .remove()
        slider.select(".background")
            .attr("height", 30)
        handle = slider.append("rect")
          .attr("class", "handle")
          .attr("transform", "translate(0," + 11 + ")")
          .attr("width", 6)
          .attr("height", 11)
          .attr("x", timeScale(currentTime))
        label = slider.append("text")
          .attr
            "class": "label"
            "transform": "translate(4," + 5 + ")"
            "text-anchor": "middle"
            "x": timeScale(currentTime)
          .text(currentTime)
        brush.on("brush", () =>
          value = timeScale.invert(d3.mouse(slider.node())[0])
          currentTime =  Math.round(value)
          brush.extent([value, value])
          handle.attr("x", timeScale(value))
          label.attr("x", timeScale(value))
          label.text(currentTime)
          g.selectAll(".state")
            .attr
              "id" : (d) -> d.id
              "class" : modes[mode].stateClass
        )
      timeAxis.attr("display", if mode is "protection" then "inherit" else "none")


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
