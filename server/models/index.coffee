common = require '../common'
module.exports = (mongoose) ->
  counter: require('./counter')(mongoose)
  timePatterns: require('./timePatterns')(mongoose, common.crudModelFactory)