common = require '../common'
slug = require './slug'

module.exports = (app) ->

  slug: slug
  timePattern: common.crudControllerFactory app.models.timePatterns