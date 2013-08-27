sinon = require 'sinon'
module.exports =
  mongoose: require './mongoose'
  sinon: sinon
  crudControllerFactory: require './crudControllerFactory'
  crudModelFactory: require './crudModelFactory'
  exportsCrudModel: require './exportsCrudModel'