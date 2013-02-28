counter = require './counter'
module.exports =
  crud: require './crud'
  counter: counter
  loadSchemas: (mongoose) ->
    counter.loadSchema mongoose