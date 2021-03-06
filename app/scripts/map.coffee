define ["d3", "topojson", "./callout", "assets/counties.topo.json", "assets/census_data.json"], (d3, topojson, callout, _vectorMap, data) ->

  vectorMap = _vectorMap
  countyGeometries = topojson.feature(vectorMap, vectorMap.objects.counties).features
  countyGeometries.forEach (d) -> d.entry = _.find(data, (entry) -> entry.id is +d.id )
  stateGeometries = topojson.feature(vectorMap, vectorMap.objects.states).features
  nationGeometries = topojson.feature(vectorMap, vectorMap.objects.nation).features
  path = d3.geo.path().projection(null)
  scale = 1

  projection = d3.geo.albersUsa().scale(1280).translate([960/2,600/2])
  circleScale = d3.scale.linear().domain([0,50]).range([0,200])

  mostRecentYear = 2015

  # tempData = null
  # d3.csv("./assets/census_race.csv",
  #   (d,i) ->
  #     {
  #       id: +d.stcounty
  #       stateId: +d.st
  #       countyName: d["countyname"]
  #       latino: +d["SShisp_1000_edit"]
  #       white: +d["SSwh_1000_edit"]
  #       black: +d["SSafam_1000_edit"]
  #       indian: +d["SSaian_1000_edit"]
  #       asianpac: +d["SSapi_1000_edit"]
  #     }
  #   ,(err, _data) =>
  #     tempData = _data
  #     console.log JSON.stringify(tempData)
  #   )

  myScale = {
    black: d3.scale.threshold()
      .domain([0, 0.01, 0.1, 0.2, 0.3, 0.7, 1])
      .range([0, 0, 0.1, 0.4, 0.6, 0.8, 1, 1])
    white: d3.scale.threshold()
      .domain([0, 0.01, 0.7, 1.5, 2, 3.2, 4.2])
      .range([0, 0, 0.1, 0.2, 0.4, 0.51, 1, 1])
    latino: d3.scale.threshold()
      .domain([0, 0.01, 0.09, 0.1, 0.2, 0.4, 1])
      .range([0, 0, 0.1, 0.4, 0.6, 0.8, 1, 1])
    indian: d3.scale.threshold()
      .domain([0,0.01,0.1,0.2,0.3,0.4,1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
    asianpac: d3.scale.threshold()
      .domain([0, 0.001, 0.01, 0.005, 0.08, 0.13, 1])
      .range([0,0,0.1,0.4,0.6,0.8,1])
  }

  regionByName = {
    "Pacific": {
      states: ["Alaska", "California", "Hawaii", "Oregon", "Washington"]
      centroid: [-118.5,32.9]
      offset: [-39.48530542559064, -15.370925469394933]
    }
    "Mountain": {
      states: ["Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico", "Utah", "Wyoming"]
      centroid: [-111,40]
      splitLabelCentroid: [-111,51]
      offset: [-7.987967225259922, 1.193425583016392]
    }
    "Midwest": {
      states: ["Illinois", "Indiana", "Iowa", "Kansas", "Michigan", "Minnesota", "Missouri", "Nebraska", "North Dakota", "Ohio", "South Dakota", "Wisconsin"]
      centroid: [-92,43]
      splitLabelCentroid: [-92,51.76]
      offset: [17.14660810580267, -5.690153784351679]
    }
    "South": {
      states: ["Alabama", "Arkansas", "Delaware", "Florida", "Georgia", "Kentucky", "Louisiana", "Maryland", "Mississippi", "North Carolina", "Oklahoma", "South Carolina", "Tennessee", "Texas", "Virginia", "District of Columbia", "West Virginia"]
      centroid: [-89,32]
      splitLabelCentroid: [-89,25]
      offset: [16.69364734000476, 20.69134832167154]
    }
    "Northeast": {
      states: ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "New Jersey", "New York", "Pennsylvania", "Rhode Island", "Vermont"]
      centroid: [-71,42.5]
      offset: [31.406069531500407, -3.9391785272940893]
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

  stateNameAbbreviations = {
    "Alabama":"AL"
    "Alaska":"AK"
    "Arizona":"AZ"
    "Arkansas":"AR"
    "California":"CA"
    "Colorado":"CO"
    "Connecticut":"CT"
    "Delaware":"DE"
    "Washington DC":"DC"
    "Florida":"FL"
    "Georgia":"GA"
    "Hawaii":"HI"
    "Idaho":"ID"
    "Illinois":"IL"
    "Indiana":"IN"
    "Iowa":"IA"
    "Kansas":"KS"
    "Kentucky":"KY"
    "Louisiana":"LA"
    "Maine":"ME"
    "Maryland":"MD"
    "Massachusetts":"MA"
    "Michigan":"MI"
    "Minnesota":"MN"
    "Mississippi":"MS"
    "Missouri":"MO"
    "Montana":"MT"
    "Nebraska":"NE"
    "Nevada":"NV"
    "New Hampshire":"NH"
    "New Jersey":"NJ"
    "New Mexico":"NM"
    "New York":"NY"
    "North Carolina":"NC"
    "North Dakota":"ND"
    "Ohio":"OH"
    "Oklahoma":"OK"
    "Oregon":"OR"
    "Pennsylvania":"PA"
    "Rhode Island":"RI"
    "South Carolina":"SC"
    "South Dakota":"SD"
    "Tennessee":"TN"
    "Texas":"TX"
    "Utah":"UT"
    "Vermont":"VT"
    "Virginia":"VA"
    "Washington":"WA"
    "West Virginia":"WV"
    "Wisconsin":"WI"
    "Wyoming":"WY"
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
    "Delaware":{
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
    "Utah": {
       SO: 2015
       SOGI:  2015
    }
  }

  bubbleTimeout = null

  isSOProtected = (id, _currentTime) ->
    _currentTime = _currentTime or currentTime
    if not sogiDates[index[id].fullName]? then return false
    if sogiDates[index[id].fullName].SO?
      if sogiDates[index[id].fullName].SO <= _currentTime
        return true
    false


  isSOGIProtected = (id) ->
    if not sogiDates[index[id].fullName]? then return false
    if sogiDates[index[id].fullName].SOGI?
      if sogiDates[index[id].fullName].SOGI <= currentTime
        return true
    false

  #destroy non-states and sort states by SO protection
  stateGeometries = stateGeometries.filter (state) -> index[state.id]?
  stateGeometries.sort (a,b) ->
    aStatus = isSOProtected(a.id, mostRecentYear)
    bStatus = isSOProtected(b.id, mostRecentYear)
    aStatus - bStatus

  modes = {
    protection : {
      stateClass: (d) ->
          if not isSOProtected(d.id) then return "no state"
          if isSOGIProtected(d.id) then return "sogi state"
          if isSOProtected(d.id) then return "so state"
      countyClass : "county hidden"
    }
    bubble : {
      stateClass: "no state"
      countyClass : "county hidden"
      countyMouseEnter : null
    }
    ethnicity : {
      stateClass: (d) -> if sogiDates[index[d.id]?.fullName]? then "state nofill protected" else "state nofill"
      countyClass : "county"
    }
    silhouette: {
      stateClass: "gray state"
      countyClass : "county hidden"
    }
  }

  ethnicities = ["latino", "black", "white", "asianpac", "indian"]
  formatCountyCalloutData = (d, activeEthnicity) ->
    if d.countyName.length is 0 then return []
    toRet = {}
    toRet.name = d.countyName.split(",")[0].trim()+", "+stateNameAbbreviations[d.countyName.split(",")[1].trim()]
    toRet.subSpanText = []
    toRet.subSpanText.push {label: "Latino                 ", value: "#{d3.format(".2f") d.latino}", bold: false}
    toRet.subSpanText.push {label: "African-American       ", value: "#{d3.format(".2f") d.black}", bold: false}
    toRet.subSpanText.push {label: "White                  ", value: "#{d3.format(".2f") d.white}", bold: false}
    toRet.subSpanText.push {label: "Asian/Pacific Islander ", value: "#{d3.format(".2f") d.asianpac}", bold: false}
    toRet.subSpanText.push {label: "Native American        ", value: "#{d3.format(".2f") d.indian}", bold: false}
    toRet.subSpanText[_.indexOf(ethnicities, activeEthnicity)].bold = true
    toRet.stroke = "#FB9F37"
    [toRet]

  formatStateCalloutData = (d) ->
    toRet = {}
    toRet.name = index[d.id].fullName
    toRet.subSpanText = []
    if isSOProtected(d.id)
      toRet.subSpanText.push {label: "Sexual Orientation Protection", value: "Y", bold: "false", bold: false}
    if isSOGIProtected(d.id)
      toRet.subSpanText.push {label: "Gender Identity Protection", value: "Y", bold: "false", bold: false}
    toRet.stroke = "#FF0055"
    [toRet]

  timeScale = d3.scale.linear()
      .domain([1977, mostRecentYear])
      .range([0, 200])
      .clamp(true)
  brush = d3.svg.brush()
      .x(timeScale)
      .extent([0, 0])
  currentTime = mostRecentYear

  map = (props) ->
    ethnicity = props.ethnicity ? "black"
    split = props.split
    mode = props.mode

    circleScale.domain([0, props.bubbleTopBound ? 50])

    if props.scaling is "cover"
      verticalPadding = 90
      horizonalPadding = props.size[0] * 0.075
      scale = Math.min (props.size[0] - horizonalPadding * 1)/960, (props.size[1] - verticalPadding * 1.5)/600
      scale *= 0.95
    else if props.scaling is "composite"
      verticalPadding = 105
      horizonalPadding = props.size[0] * 0.075
      scale = Math.min (props.size[0] - horizonalPadding * 1)/960, (props.size[1] - verticalPadding * 1)/600
      scale *= 0.9
    else
      verticalPadding = 180
      horizonalPadding = props.size[0] * 0.1
      scale = Math.min (props.size[0] - horizonalPadding * 1)/960, (props.size[1] - verticalPadding * 1.5)/600
      scale *= 0.9

    transform = "translate(#{horizonalPadding}, #{verticalPadding}) scale(#{scale}) "
    g = @.selectAll("g#vectorMap").data([null])
    g.enter()
      .append("g").attr("id" : "vectorMap")
      .attr "transform", transform
    g.transition().duration(600).ease("cubic-out")
      .attr "transform", transform

    calloutSurface = @
    calloutTransform = (coords) ->
      coords[0] = coords[0] * scale + horizonalPadding
      coords[1] = coords[1] * scale + verticalPadding
      coords

    # county definitions
    countyPaths = g.selectAll("path.county").data(countyGeometries)
    countyPaths.enter()
      .append("path")
      .attr
        "d" : path
        "id" : (d) -> d.id
        "fill-opacity": 0
      .on "mouseleave", (d) =>
        bubbleTimeout = setTimeout((() =>
          callout.call calloutSurface, path.centroid(d), [])
          g.selectAll("path.overlayCounty").data([]).exit().remove()
        , 500)
    countyPaths
      .on "mouseenter", (d) ->
        if bubbleTimeout?
          clearTimeout(bubbleTimeout)
        callout.call calloutSurface, calloutTransform(path.centroid(d)), formatCountyCalloutData( _.find(data, (entry) -> entry.id is +d.id ), ethnicity)
        overlayCounty = g.selectAll("path.overlayCounty").data([d3.select(@).attr("d")])
        overlayCounty.enter().append("path")
          .attr
            "class": "overlayCounty"

        overlayCounty
          .attr
            "d": (d) -> d
      .attr
        "class" : modes[mode].countyClass
        "fill-opacity" : (d,i) -> myScale[ethnicity](d.entry?[ethnicity])

    #state definitions
    # g = @.selectAll("g").data([null])
    # g.enter().append("g").attr("id" : "vectorMap").attr("transform","translate(100,0)")
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
        "class" : (d, i) ->
          d3.functor(modes[mode].stateClass)(d, i) + (if props.fill? then " #{ props.fill }-fill" else "")
        "vector-effect": "non-scaling-stroke"
      .style
        "stroke": (d) ->
          if props.showProtection and isSOProtected(d.id,mostRecentYear) then "black"
      .on "mouseenter", (d) =>
        if mode in ["bubble", "silhouette"] then return
        if bubbleTimeout?
          clearTimeout(bubbleTimeout)
        adjustedCentroid = path.centroid(d)
        offset = d3.select(d.parentRegion).attr("transform")?.match(/[0-9., -]+/)?[0].split(",") || ["0","0"]
        adjustedCentroid[0] += +offset[0]
        adjustedCentroid[1] += +offset[1]
        callout.call calloutSurface, calloutTransform(adjustedCentroid.map((d) -> d)), formatStateCalloutData(d)
      .on "mouseleave", (d) =>
        bubbleTimeout = setTimeout((() => callout.call calloutSurface, path.centroid(d), []), 500)

    #region definitions
    if mode isnt "ethnicity"
      g.selectAll(".region")
        .transition()
        .delay((d,i) -> 750*Math.sqrt((5-i)/5))
        .duration(500)
        .attr("transform", (d) =>
          if split
            x = regionByName[d].offset[0]
            y = regionByName[d].offset[1]
            "translate(#{x},#{y})"
          else
            "translate(0,0)"
        )
    else
      g.selectAll(".region")
        .transition().duration(0)
        .attr("transform", (d) =>
            "translate(0,0)"
        )

    regionOverlay = g.selectAll(".regionOverlay")
    if regionOverlay.empty()
      regionOverlay = g.append("g").classed("regionOverlay",true)

    unscaledRegionOverlay = @.selectAll(".unscaledRegionOverlay")
    if unscaledRegionOverlay.empty()
      unscaledRegionOverlay = @.append("g").classed("unscaledRegionOverlay",true)

    regionBubbleData = []
    regionLabelData = []
    if mode is "bubble"
      regionBubbleData = _.keys(regionByName)
    if mode is "protection" and split
      regionLabelData = _.keys(regionByName)
      regionLabelData = regionLabelData.filter (d) -> regionByName[d].splitLabelCentroid?

    #bubble
    regionBubble = regionOverlay.selectAll(".regionBubble").data(regionBubbleData)
    regionBubble.enter().append("g")
      .attr
        "class": "regionBubble"
      .call (enteringBubble) ->
        enteringBubble
          .append('circle')
          .attr
            class: 'circle-solid'
            fill: props.bubbleColor
            r: 0
        enteringBubble
          .append('path')
          .attr
            class: 'circle-dashed'
            d: "M0 0 A0 0 0 1 0 0 0"
            # stroke: 'gray'
            fill: 'none'
            opacity: 0
            'stroke-dasharray': '5 7'
            'stroke-width': 2.4
        enteringBubble
          .append('text')
          .attr
            class: 'circle-dashed-label'
            # fill: 'gray'
            stroke: 'none'
            dy: ".25em"
            opacity: 0
            "font-family": "'Libre Baskerville', serif"
            "font-size": "22px"
            "text-anchor": 'middle'

    regionBubble
      .attr
        "transform": (d) ->
          centerPt = projection(regionByName[d].centroid)
          "translate(#{centerPt})"
      .each (d, i) ->
        # The solid circle
        solidValue =
          if props.solidCircle?
            parseFloat(props.percentageByRegion[d][props.solidCircle])
          else
            props.percentageByRegion[d]
        d3.select(@).select('.circle-solid')
          .transition().delay((d) -> 0.0 + 98*(5-i))
          .attr
            "fill": props.bubbleColor
          .attr
            "r": circleScale(solidValue)

        dashedValue = parseFloat(props.percentageByRegion[d][props.dashedCircle])
        d3.select(@).select('.circle-dashed')
          .classed "light", d3.hcl(props.bubbleColor).l < 60 and solidValue > dashedValue
          .transition().delay((d) -> 0.0 + 98*(5-i))
            .attr
              opacity: if isNaN(dashedValue) then 0 else 1
              d: ->
                return "M0 0 A0 0 0 1 0 0 0" if isNaN(dashedValue) # Bail out if there's no data
                # Generate a circle path with a gap for the text:
                sign = 1
                r = circleScale dashedValue
                # the size, in pixels, of the gap (essentially the width of the text plus some padding)
                gapSize = 52
                # the size, in radians, of the gap (a function of gapSize and the circle's r)
                gapAngle = Math.asin(0.5 * gapSize / r)
                # Start and end angles of the gap (note: sign is only needed for instrumenting whether label is above or below the gap)
                a0 = sign * .5 * Math.PI - gapAngle
                a1 = sign * .5 * Math.PI + gapAngle
                # Start and end points (x,y) of the gap
                x0 = Math.round(r * Math.cos(a0))
                y0 = Math.round(r * Math.sin(a0))
                x1 = Math.round(r * Math.cos(a1))
                y1 = Math.round(r * Math.sin(a1))
                # Build and return the circle-with-gap path
                "M#{x0} #{y0} A#{r} #{r} 0 1 0 #{x1} #{y1}"

        d3.select(@).select('.circle-dashed-label')
          .classed "light", d3.hcl(props.bubbleColor).l < 60 and solidValue > dashedValue
          .transition().delay((d) -> 0.0 + 98*(5-i))
            .attr
              opacity: if isNaN(dashedValue) then 0 else 1
              y: if isNaN(dashedValue) then 0 else circleScale dashedValue
            .text if isNaN(dashedValue) then '' else dashedValue + '%'

    exit_transition = regionBubble.exit()
      .transition().duration(600).ease("cubic-out")
    exit_transition.select(".circle-solid").attr("opacity", 0)
    exit_transition.select(".circle-dashed").attr("opacity", 0)
    exit_transition.select(".circle-dashed-label").attr("opacity", 0)
    exit_transition.remove()

    #name
    regionLabelBrown = unscaledRegionOverlay.selectAll(".regionLabel.brown").data(regionBubbleData)
    regionLabelBrown.enter().append("text")
        .attr
          "class": "regionLabel brown"
          "opacity": 0
    regionLabelBrown
      .attr
        "x": (d) => projection(regionByName[d].centroid)[0] * scale + horizonalPadding
        "y": (d) => projection(regionByName[d].centroid)[1] * scale + verticalPadding + 18
      .text((d) -> d)
      .transition().delay((d,i) -> 0.0 + 98*(5-i))
        .attr
          "fill": d3.rgb(props.bubbleColor).darker()
          "opacity": 1
    regionLabelBrown.exit().remove()

    #alternate, non-bubble name
    regionLabelGray = unscaledRegionOverlay.selectAll(".regionLabel.gray").data(regionLabelData)
    regionLabelGray.enter().append("text")
        .attr
          "class": "regionLabel gray"
          "opacity": 0
    regionLabelGray
      .attr
        "x": (d) => projection(regionByName[d].splitLabelCentroid)[0] * scale + horizonalPadding
        "y": (d) => projection(regionByName[d].splitLabelCentroid)[1] * scale + verticalPadding
      .text((d) -> d)
      .transition().delay((d,i) -> 1000 + 250*(5-i))
        .attr
          "opacity": 1
    regionLabelGray.exit().remove()

    regionLine = unscaledRegionOverlay.selectAll(".regionLine").data(regionLabelData)
    regionLine.enter().append("line")
        .attr
          "class": "regionLine"
          "opacity": 0
    regionLine
      .attr
        "x1": (d) => projection(regionByName[d].splitLabelCentroid)[0] * scale + horizonalPadding
        "y1": (d) => projection(regionByName[d].splitLabelCentroid)[1] * scale + verticalPadding
        "x2": (d) => projection(regionByName[d].splitLabelCentroid)[0] * scale + horizonalPadding
        "y2": (d) => projection(regionByName[d].centroid)[1] * scale + verticalPadding
        "stroke-dasharray": "0,20,200"
      .transition().delay((d,i) -> 1000 + 250*(5-i))
        .attr
          "opacity": 1

    regionLine.exit().remove()


    #percentage
    regionPercent = unscaledRegionOverlay.selectAll(".regionPercent").data(regionBubbleData)
    regionPercent.enter().append("text")
        .attr
          "class": "regionPercent"
          "opacity": 0
    regionPercent
      .attr
        "x": (d) => projection(regionByName[d].centroid)[0] * scale + horizonalPadding
        "y": (d) => projection(regionByName[d].centroid)[1] * scale + verticalPadding
      .text (d) =>
        if props.solidCircle?
          props.percentageByRegion[d][props.solidCircle]
        else
          if props.isPercentage ? true
            "#{props.percentageByRegion[d]}\%"
          else
            props.percentageByRegion[d]
      .transition().delay((d,i) -> 0.0 + 98*(5-i))
        .attr
          "opacity": 1
    regionPercent.exit().remove()


    # interactivityInstruction = calloutSurface.select(".interactivityInstruction")
    # if interactivityInstruction.empty()
    #   interactivityInstruction = calloutSurface.append("text")
    #     .attr
    #       "class": "interactivityInstruction"
    #     .text "Hover to explore"
    # interactivityInstruction
    #   .attr
    #     "transform": "translate(#{props.size[0] * 0.45},#{props.size[1] * 0.14})"
    #     "display": if mode is "protection" or mode is "ethnicity" then "inherit" else "none"

    # console.log mode, interactivityInstruction.attr "display"


    #timescale
    timeScale.range ([0,props.size[0] * 0.5])
    timeAxis = calloutSurface.select(".timeAxis")
    handle = calloutSurface.select(".handle")
    if timeAxis.empty()
      timeAxis = calloutSurface.append("g")
          .attr
            "class": "timeAxis"
      timeAxis.append("g")
        .attr
          "class": "visibleAxis"
      slider = timeAxis.append("g")
          .attr
            "class": "slider"
      slider.selectAll(".extent,.resize")
          .remove()
      slider.select(".background")
          .attr("height", 30)
      sliderInstruction = timeAxis.append("text")
        .attr
          "class": "sliderInstruction"
        .text "Drag to explore timeline."
      handle = timeAxis.append("g")
        .attr
          "class": "handle"
          "transform": "translate(#{timeScale(currentTime)}," + 0 + ")"
        .call(brush)
      handle.append("rect")
        .attr
            "transform": "translate(-3," + -5 + ")"
            "width": 6
            "height": 11
      label = handle.append("text")
        .attr
          "class": "sliderLabel"
          "transform": "translate(0," + -9 + ")"
          "text-anchor": "middle"
        .text(currentTime)
      brush.on("brush", () =>
        value = timeScale.invert(d3.mouse(slider.node())[0])
        currentTime =  Math.round(value)
        brush.extent([value, value])
        handle.attr("transform", "translate(#{timeScale(currentTime)}," + 0 + ")")
        label.text(currentTime)
        g.selectAll(".state")
          .attr
            "id" : (d) -> d.id
            "class" : modes["protection"].stateClass
        timeAxis.select(".sliderInstruction")
          .transition().duration(1000)
            .attr
              "opacity": 0
      )
    handle.attr("transform", "translate(#{timeScale(currentTime)}," + 0 + ")")
    timeAxis.attr
      "display": if mode is "protection" then "inherit" else "none"
      "transform": "translate(#{props.size[0] * 0.25},#{props.size[1] * 0.9})"
    timeAxis.select(".visibleAxis").call(d3.svg.axis()
      .scale(timeScale)
      .orient("bottom")
      .tickValues([1977,mostRecentYear])
      .tickFormat(d3.format(".0f"))
    )
    timeAxis.select(".sliderInstruction")
      .attr
        "transform": "translate(#{timeScale(mostRecentYear) + 20}," + 2 + ")"


    ### Label ###
    label_sel = @select(".label")
    if label_sel.empty()
      label_sel = @append("text").attr("class", "label")
        .attr "fill-opacity": 0
        .attr "transform", "translate(#{ props.size[0]/2 }, #{ props.size[1] - 60 })"
    label_sel.transition().duration(600).ease("cubic-out")
      .attr "transform", "translate(#{ props.size[0]/2 }, #{ props.size[1] - 60 })"
      .attr "text-anchor", "middle"
      .attr "y", 27
      .attr "fill-opacity": 1
    tspan_sel = label_sel.selectAll("tspan").data props.label?.split("\n") ? []
    tspan_sel.enter().append("tspan")
      .attr "dy", 15
      .attr "x", 0
    tspan_sel.text(String)
    tspan_sel.exit().remove()
    ######


  map.getColorsForEthnicity = (ethnicity) ->
    shades = [0.1,0.4,0.6,0.8]
    colors = []
    domain = myScale[ethnicity].domain()
    [1..4].forEach (i) ->
      colors.push { value: "#ED8F28", label: "#{myScale[ethnicity].domain()[i]} – #{myScale[ethnicity].domain()[i+1]}", alpha: shades[i-1] }
    colors.push { value: "#ED8F28", label: "#{myScale[ethnicity].domain()[5]}+", alpha: 1}
    return colors.reverse()

  map.deps = ["#vectorMap", ".timeAxis", ".calloutSurface", ".interactivityInstruction"]

  map
