sinon = require 'sinon'
crudFactory = require './crudModelFactory'
modelFactory = require './modelFactory'

module.exports =
  crudFactory: crudFactory
  modelFactory: modelFactory
  schemaFactory: (def) ->
    def.schemaDefinition