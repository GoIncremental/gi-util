module.exports = (Resource) ->
  find: 'crudModel find'
  findById:  'crudModel findById'
  findOne: 'crudModel findOne'
  findOneBy:  'crudModel findOneBy'
  create: 'crudModel create'
  update: 'crudModel update'
  destroy: 'crudModel destroy'
  name: Resource.modelName