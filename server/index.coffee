module.exports = (mongoose) ->
  exports.models = require('./models')(mongoose)
  exports.controllers = require './controllers/controllers'