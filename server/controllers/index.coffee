common = require '../common'
slug = require './slug'
geo = require './geo'

module.exports = (app) ->

  slug: slug
  timePattern: common.crudControllerFactory app.models.timePatterns
  geo: geo
