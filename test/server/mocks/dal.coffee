sinon = require 'sinon'
crudFactory = require './crudModelFactory'
modelFactory = require './modelFactory'

module.exports =
  crudFactory: crudFactory
  modelFactory: modelFactory
  schemaFactory: (def) ->
    res = def.schemaDefinition
    res.virtual = () ->
      get: ->
      set: ->
    res.methods = {}
    res.pre = () ->
    res