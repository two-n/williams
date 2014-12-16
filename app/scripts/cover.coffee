define ["d3", "underscore", "./clean", "./map"], (d3, _, clean, map) ->
  (props) ->
    clean.call @, [], =>