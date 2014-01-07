extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

module.exports =
  extend: extend
  rest: require './rest'
  timePatterns: require '../../common/timePatterns'
  dal: require './dal'
  crudControllerFactory: require './crudControllerFactory'
  crudModelFactory: require './crudModelFactory'