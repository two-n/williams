define ->
  [{
    "url": "/cover/1",
    "heading": "A Data Portrait of LGBT People\nin the Midwest, Mountain, and Southern States",
    "type": "cover"
  }, {
    "url": "/introduction/1",
    "heading": "Public Opinions are shifting,\nbut LGBT workers are still vulnerable."
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
    "heading": "Public Opinions are shifting,\nbut LGBT workers are still vulnerable."
    "colors": [
      { value: "#FF0055", label: "SOGI protection*", alpha: 1},
      { value: "#FF7D96", label: "SO protection*", alpha: 1 },
      { value: "#FFFFFF", label: "No protection", alpha: 1 }
    ],
    "type": "map"
    "split": false
    "mode": "protection"
    "label": "Timeline Map of Employment Protection Policies",
  }, {
    "url": "/introduction/3",
    "heading": "Public Opinions are shifting,\nbut LGBT workers are still vulnerable."
    "colors": [
      { value: "#FF0055", label: "SOGI protection*", alpha: 1 },
      { value: "#FF7D96", label: "SO protection*", alpha: 1},
      { value: "#FFFFFF", label: "No protection", alpha: 1 }
    ],
    "type": "map"
    "split": true
    "mode": "protection"
    "label": "Timeline Map of Employment Protection Policies",
  }, {
    "url": "/ethnicity/1",
    "heading": "Midwestern, Mountain and Southern states are home\nfor a majority of LGBT people."
    "type": "map",
    "split": true,
    "mode": "bubble",
    "colors": [
      { value: "#FFFFFF", label: "US map by region" },
      { value: "#FF9C00", label: "LGBT population" }
    ],
    "percentageByRegion": {
      "Pacific": 17,
      "Mountain": 8,
      "Midwest": 20,
      "South": 35,
      "Northeast": 19
    },
    "label": "Percentage of LGBT Population per Region",
  }, {
    "url": "/ethnicity/2",
    "heading": "Midwestern, Mountain and Southern states are home\nfor a majority of LGBT people."
    "colors": [
      { label: "LGBT Ethnicity\nDistribution", value: ["#FF9C00", "#FFAE48", "#FCBF75", "#F5D6B3"] },
      { label: "Non-LGBT Ethnicity\nDistribution", value: ["#B4B3B9", "#C5C5C9", "#D1D1D4", "#E2E2E3"] }
    ],
    "type": "pies",
    "pies": ["Pacific", "Mountain", "Midwest", "South", "Northeast"],
    # "slices": ["White LGBT", "African-American LGBT", "Latino/a2 LGBT", Asian/Pacific Islander LGBT"],
    "slices": ["White LGBT", "African-American LGBT", "Latino/a2 LGBT", "Asian/Pacific Islander LGBT"],
    # "outer-slices": ["White Non-LGBT", "African-American Non-LGBT", "Latino/a2 Non-LGBT", "American Indian/Alaska Native Non-LGBT", "Asian/Pacific Islander Non-LGBT"],
    "outer-slices": ["White Non-LGBT", "African-American Non-LGBT", "Latino/a2 Non-LGBT", "Asian/Pacific Islander Non-LGBT"],
    "data": """
      ,White LGBT,White Non-LGBT,African-American LGBT,African-American Non-LGBT,Latino/a2 LGBT,Latino/a2 Non-LGBT,American Indian/Alaska Native LGBT,American Indian/Alaska Native Non-LGBT,Asian/Pacific Islander LGBT,Asian/Pacific Islander Non-LGBT
      Individuals,,,,,,,,,,
      All Individuals in the US,63%,72%,15%,12%,18%,13%,n/d,n/d,2%,1%
      21 Protective States,61%,69%,12%,9%,23%,17%,n/d,n/d,3%,3%
      29 Non-Protective States,65%,74%,18%,13%,14%,10%,n/d,n/d,1%,1%
      ,,,,,,,,,,
      Northeast,65%,74%,15%,11%,16%,12%,n/d,n/d,2%,2%
      Midwest,74%,82%,13%,10%,10%,6%,n/d,n/d,1%,1%
      South,59%,67%,22%,17%,16%,13%,n/d,n/d,1%,1%
      Mountain,66%,77%,4%,3%,26%,17%,n/d,n/d,2%,1%
      Pacific,55%,61%,7%,6%,30%,26%,n/d,n/d,4%,5%
    """
    "label": "Ethnicity Distribution by Region",
  }, {
    "url": "/ethnicity/3",
    "heading": "Midwestern, Mountain and Southern states are home\nfor a majority of LGBT people."
    "type": "map"
    "mode": "ethnicity"
    "label": "Ethnicity Distribution by County"
  }, {
    "url": "/education/1",
    "heading": "College completion is lowest\namong LGBT people in the Midwest"
    "colors": [
      { value: "#fadc52", label: "LGBT" }
    ],
    "type": "composite",
    # "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT"],
    "data": """
      ,LGBT,Non-LGBT
      All Individuals in the US,34%,34%
      21 Protective States,39%,38%
      29 Non-Protective States,31%,31%
      ,,
      Northeast,39%,39%
      Midwest,29%,32%
      South,33%,32%
      Mountain,34%,35%
      Pacific,39%,35%
    """,
    # "label": "Percentage of individuals\nover age 25 with a college degree (%)"
    "label": "Percentage of LGBT Population\nwith College Degrees",
  }, {
    "url": "/education/2",
    "heading": "College completion is lowest\namong LGBT people in the Midwest"
    "colors": [
      { value: "#fadc52", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "composite",
    # "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "data": """
      ,LGBT,Non-LGBT
      All Individuals in the US,34%,34%
      21 Protective States,39%,38%
      29 Non-Protective States,31%,31%
      ,,
      Northeast,39%,39%
      Midwest,29%,32%
      South,33%,32%
      Mountain,34%,35%
      Pacific,39%,35%
    """,
    # "label": "Percentage of individuals\nover age 25 with a college degree (%)"
    "label": "Percentage of Population\nwith College Degrees",
  }, {
    "url": "/economic-insecurity/1",
    "heading": "“It is not just that LGBT people in the Midwest\nand South are poorer because people in\nthose regions tend to be poorer overall…”\n\n-Dr. Gary J. Gates",
    "colors": [
      { value: "#00C775", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "composite",
    "bars": ["LGBT", "Non-LGBT"],
    "data": """
      ,LGBT,Non-LGBT,"Odds Ratio of Reporting a Household Income Below $24,000 (LGBT:Non-LGBT)"
      All Individuals,32%,24%,1.3155737705
      21 Protective States,29%,22%,1.2981120697
      29 Non-Protective States,35%,26%,1.3463865742
      Northeast,29%,22%,1.3236786143
      Midwest,35%,24%,1.4878838431
      South,33%,27%,1.2437152726
      Mountain,33%,22%,1.4776068344
      Pacific,30%,24%,1.2374978272
    """,
    # "label": "Percentage of individuals\nwith household income below $24,000 (%)"
    "label": "Percentage of Population\nEarning less than $24,000 Annually",
  }, {
    "url": "/economic-insecurity/2",
    "heading": "“It is not just that LGBT people in the Midwest\nand South are poorer because people in\nthose regions tend to be poorer overall…”\n\n-Dr. Gary J. Gates",
    "colors": [
      { value: "#00C775", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "composite",
    # "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
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
    # "label": "Percentage of individuals\nreporting not having enough money for food (%)"
    "label": "Percentage of Population\nReporting Food Insecurity",
  }, {
    "url": "/health/1",
    "heading": "Healthcare and HIV",
    "colors": [
      { value: "#0075CA", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "bar-chart",
    "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "benchmark": "All Individuals ",
    "data": """
      ,LGBT,Non-LGBT,Odds Ratio of Not Having Enough Money for Health Care (LGBT: Non-LGBT)
      All Individuals ,26,18,1.4515104577
      21 Protective States,23,16,1.45
      29 Non-Protective States,28,19,1.47
      Northeast,22,15,1.5
      Midwest,26,17,1.57
      South,28,20,1.38
      Mountain,27,17,1.57
      Pacific,25,17,1.41
    """,
    # "label": "Percentage of individuals\nreporting not having enough money for health care (%)"
    "label": "Percentage of Population\nReporting They Cannot Afford Healthcare",
  }, {
    "url": "/health/2",
    "heading": "Healthcare and HIV",
    "colors": [
      { value: "#0075CA", label: "LGBT" },
      { value: "#D1D1D4", label: "Non-LGBT" }
    ],
    "type": "bar-chart",
    "rows": ["21 Protective States", "29 Non-Protective States", null, "Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["LGBT", "Non-LGBT"],
    "benchmark": "All Individuals ",
    "benchmark-orientation": ["end", "start"],
    "bounds": [0, 100],
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
    # "label": "Percentage of individuals\nover age 18 with health insurance (%)"
    "label": "Percentage of Adult Population\nwith Health Insurance",
  }, {
    "url": "/health/3",
    "heading": "Healthcare and HIV",
    "colors": [
      { value: "#0075CA", label: "MSM* population" },
      { value: "#D1D1D4", label: "All population" }
    ],
    "type": "bar-chart",
    "rows": ["Northeast", "Midwest", "South", "Mountain", "Pacific"],
    "bars": ["MSM* population", "All population"]
    "data": """
      ,MSM* population,All population
      Midwest,25.3807333693,10.6737091979
      Mountain,61.6291914618,10.6892735371
      South,53.9237776197,25.1307924563
      Northeast,47.2310998196,21.6339402335
      Pacific,56.0973474114,16.214802417
    """,
    # "label": "HIV diagnoses by region, rates per 100k\n4 year average"
    "label": "Current HIV Diagnoses by Region,\nRates per 100k",
  }, {
    "url": "/conclusion/1",
    "type": "conclusion",
    "quote": "In states where legal climates are less\nsupportive of LGBT people, social stigma\ntoward them is also higher.\n\nSocial and legal climates are generally\nintertwined such that supportive laws and\nsocial acceptance run hand in hand.",
    "attribution": "–Andrew Flores,\nWilliams Public Opinion\nProject Director"
  }]
