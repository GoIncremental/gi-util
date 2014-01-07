common = require '../common'
module.exports = (dal) ->
  counters: require('./counters')(dal)
  timePatterns: require('./timePatterns')(dal)
  resources: require('./resources')(dal)