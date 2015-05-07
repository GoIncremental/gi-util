common = require '../common'
module.exports = (dal) ->

  modelDefinition =
    name: 'Resource'
    schemaDefinition:
      systemId: 'ObjectId'
      name: 'String'

  modelDefinition.schema = dal.schemaFactory modelDefinition
  model = dal.modelFactory modelDefinition
  crud = dal.crudFactory model

  registerTypes = (systemId, models, cb) ->
    for key, val of models
      resourceType =
        name: val.name
        systemId: systemId
      crud.update val._id
      , resourceType
      , cb

  exports = common.extend {}, crud
  exports.registerTypes = registerTypes
  exports
