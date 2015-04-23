extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

log = require "./log"

module.exports =
  extend: extend
  rest: require './rest'
  timePatterns: require '../../common/timePatterns'
  dal: require './dal'
  crudControllerFactory: require './crudControllerFactory'
  crudModelFactory: require './crudModelFactory'
  log: log.log
  configure: log.configure
