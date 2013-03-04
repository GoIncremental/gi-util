counter = require './counter'
module.exports =
  crud: require './crud'
  mongo: require './mongo'
  counter: counter

  loadSchemas: (mongoose) ->
    counter.loadSchema mongoose