extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

registerResourceTypes = (mongoose, models) ->
  mongoose.models['System'].find {}, (err, systems) ->
    systems.forEach (system) ->
      for key, val of models
        resourceType =
          name: val.name
          systemId: system._id

        mongoose.models['Resource'].update resourceType
        , resourceType
        , {upsert: true}
        , (err) ->
          if err
            console.log err

module.exports =
  extend: extend
  rest: require './rest'
  timePatterns: require '../../common/timePatterns'
  mongo: require './mongo'
  registerResourceTypes: registerResourceTypes