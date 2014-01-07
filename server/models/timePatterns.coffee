_ = require 'underscore'
moment = require 'moment'
common = require '../common'

module.exports = (dal) ->

  modelDefinition =
    name: 'TimePattern'
    schemaDefinition:
      systemId: 'ObjectId'
      name: 'String'
      pattern: ['Number']
      recurrence: 'String'
      base: 'Date'

  modelDefinition.schema = dal.schemaFactory modelDefinition
  model = dal.modelFactory modelDefinition
  crud = dal.crudFactory model

  checkValidPattern = (recurrence, pattern) ->
    if !recurrence? or !pattern?
      return true
    else

      secondsPerDay = 60*60*24
      expectedPeriodTotal = 0
      if recurrence is 'weekly'
        expectedPeriodTotal = secondsPerDay * 7
      else if recurrence is 'monthly'
        expectedPeriodTotal = secondsPerDay * 31
      else if recurrence is 'yearly'
        expectedPeriodTotal = secondsPerDay * 365
      
      #TODO: we will need a special category and consideration for leap years
      #      does the pattern include the leap day in line, or at the end for
      #      instance

      #TODO: We need to define what we do with monthly recurrences where the
      #      calculated period total exceeds the defined period (for instance,
      #      months with fewer than 31 days)
      #      Here the right answer is somewhat simpler - just cut off the array

      calculatedPeriodTotal = 0
      for item in pattern
        calculatedPeriodTotal += item

      calculatedPeriodTotal <= expectedPeriodTotal

  create = (json, callback) ->
    if json.pattern? and json.recurrence?
      if @_checkValidPattern(json.recurrence,json.pattern)
        crud.create json, callback
      else
        callback 'pattern exceeds recurrence', null
    else
      crud.create json, callback

  update = (id, json, callback) ->
    that = @
    if json.recurrence? or json.pattern?
      crud.findById id, json.systemId, (err, obj) ->
        if err
          callback err, null
        else if not obj
          callback 'could not find time pattern with id ' + id, null
        else
          if json.recurrence?
            obj.recurrence = json.recurrence
          if json.pattern?
            obj.pattern = json.pattern
          if that._checkValidPattern(obj.recurrence, obj.pattern)
            crud.update id, json, callback
          else
            callback 'pattern exceeds recurrence', null

    else
      crud.update id, json, callback

  timeOnBetween = (start, stop, patternId, systemId, callback) ->
    crud.findById patternId, systemId, (err, obj) ->
      if err or not obj
        callback('Could not find pattern with id: ' + patternId) if callback
      else
        result = common.timePatterns.timeOnBetween start, stop
        , obj.pattern, obj.recurrence
        callback null, result if callback

  timeAfterXSecondsOnFrom = (start, x, patternId, systemId, callback) ->
    crud.findById patternId, systemId, (err, obj) ->
      if err or not obj
        callback('Could not find pattern with id: ' + patternId) if callback
      else
        result = common.timePatterns.timeAfterXSecondsOnFrom start, x
        , obj.pattern, obj.recurrence
        callback null, result if callback

  #Standard Crud
  exports = common.extend {}, crud
  #Crud Overrides
  exports.create = create
  exports.update = update
  #Public Methods
  exports.timeOnBetween = timeOnBetween
  exports.timeAfterXSecondsOnFrom = timeAfterXSecondsOnFrom
  #Private Methods
  exports._checkValidPattern = checkValidPattern
  exports
