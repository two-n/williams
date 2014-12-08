define ->
  [{
    "url": "/introduction/1",
    "heading": "Graph of Opinions on Marriage/Employment/Sin",
    "colors": [
      { value: "#FF0055", label: "Not Wrong at All" },
      { value: "#A6A5AC", label: "Always Wrong" },
      { value: "#C0C0C4", label: "Almost Always Wrong" },
      { value: "#D8D8DA", label: "Sometimes Wrong" }
    ],
    "type": "timeline",
    "lines": ["Not Wrong at All", "Always Wrong", "Almost Always Wrong", "Sometimes Wrong"],
    "data": """
      ,1973,1974,1976,1977,1980,1982,1984,1985,1987,1988,1989,1990,1991,1993,1994,1996,1998,2000,2002,2004,2006,2008,2010,2012
      Always Wrong,73,70,70,73,74,74,76,75,77,77,77,76,77,66,68,61,59,59,56,58,56,52,46,46
      Almost Always Wrong,7,6,6,6,6,5,5,4,4,4,4,5,4,4,4,5,6,4,5,5,5,3,4,3
      Sometimes Wrong,8,9,8,8,6,7,6,7,7,6,6,6,4,8,6,6,7,8,7,7,7,7,8,8
      Not Wrong at All,11,13,16,14,14,14,13,14,12,13,15,13,15,22,23,28,28,29,32,30,32,38,43,44
      N,1448,1412,1426,1453,1397,1771,1412,1484,1750,937,980,872,926,1012,1884,1784,1753,1697,884,868,1908,1269,1223,1239
    """,
    "label": "\"What about sexual relations\nbetween two adults of the same sex?\""
  }, {
    "url": "/introduction/2",
    "heading": "Timeline Map of Employment Laws",
    "colors": [
      { value: "#FF0055", label: "SOGI protection*", alpha: 1},
      { value: "#FF7D96", label: "SO protection*", alpha: 1 },
      { value: "#FFFFFF", label: "No protection", alpha: 1 }
    ],
    "type": "map"
    "split": false
    "mode": "protection"
  }, {
    "url": "/introduction/3",
    "heading": "Current Employment Map with Region Overlay",
    "colors": [
      { value: "#FF0055", label: "SOGI protection*", alpha: 1 },
      { value: "#FF7D96", label: "SO protection*", alpha: 1},
      { value: "#FFFFFF", label: "No protection", alpha: 1 }
    ],
    "type": "map"
    "split": true
    "mode": "protection"
  }, {
    "url": "/ethnicity/1",
    "heading": "Region Map with % LGBT Population Overlay"
    "type": "map"
    "split": true
    "mode": "bubble"
  }, {
    "url": "/ethnicity/2",
    "heading": "Pie Charts of Race/Ethnicity by Region"
  }, {
    "url": "/ethnicity/3",
    "heading": "Pie Charts of Race/Ethnicity by 21/29"
    "type": "map"
    "mode": "ethnicity"
  }, {
    "url": "/education/1",
    "heading": "Bar Chart of College Completion by 21/29"
  }, {
    "url": "/education/2",
    "heading": "Bar Chart of College Completion by Region"
    # "label":
    #   [
    #     "Percentage of population"
    #     "that completes college education (%)"
    #   ]
  }, {
    "url": "/education/3",
    "heading": "Bar Chart of College Completion by Region & SS/DS"
  }, {
    "url": "/economic-insecurity/1",
    "heading": "Bar Chart of <$24,000 by Region & SS/DS",
    "colors": [
      { value: "#00C775", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "bar-chart",
    "rows": ["21 State Law States", "29 Non-State Law States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "data": """
      ,LGBT,Non-LGBT,"Odds Ratio of Reporting a Household Income Below $24,000 (LGBT:Non-LGBT)"
      All Individuals,32%,24%,1.3155737705
      21 State Law States,29%,22%,1.2981120697
      29 Non-State Law States,35%,26%,1.3463865742
      Northeast,29%,22%,1.3236786143
      Midwest,35%,24%,1.4878838431
      South,33%,27%,1.2437152726
      Mountain,33%,22%,1.4776068344
      Pacific,30%,24%,1.2374978272
    """,
    "label": "Percentage of individuals\nwith household income below $24,000 (%)"
  }, {
    "url": "/economic-insecurity/2",
    "heading": "Bar Chart of Food Insecurity by Region & SS/DS",
    "colors": [
      { value: "#00C775", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "bar-chart",
    "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "data": """
      ,LGBT,Non-LGBT,Odds Ratio of Not Having Enough Money for Food (LGBT:Non-LGBT)
      All Individuals ,28%,18%,1.6
      21 Protective States,26%,16%,1.59
      29 Non-Protective States,30%,19%,1.63
      ,,,
      Northeast,26%,16%,1.58
      Midwest,30%,16%,1.82
      South,29%,20%,1.48
      Mountain,31%,17%,1.86
      Pacific,28%,18%,1.57
    """,
    "label": "Percentage of individuals\nreporting not having enough money for food (%)"
  }, {
    "url": "/health/1",
    "heading": "Bar Chart of No Money for Healthcare by Region & SS/DS"
  }, {
    "url": "/health/2",
    "heading": "Bar Chart of Health Insurance by Region & SS/DS",
    "colors": [
      { value: "#0075CA", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "bar-chart",
    "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "data": """
      ,LGBT,Non-LGBT,Odds Ratio of Having Health Insurance (LGBT:Non-LGBT)
      All Individuals ,82%,87%,0.95
      21 Protective States,89%,89%,1
      29 Non-Protective States,78%,85%,0.91
      Northeast,90%,90%,1
      Midwest,87%,89%,0.97
      South,76%,84%,0.91
      Mountain,81%,86%,0.93
      Pacific,84%,87%,0.97
    """,
    "label": "Percent of individuals\nover age 18 with health insurance (%)"
  }, {
    "url": "/health/3",
    "heading": "Rates of HIV Infection by Region & SS/DS"
  }, {
    "url": "/health/4",
    "heading": "Rates of HIV Occurrence by Region & SS/DS"
  }]
