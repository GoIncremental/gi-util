common = require '../common'
slug = require './slug'
geoip = require './geoip'

module.exports = (app) ->
  slug: slug
  timePattern: common.crudControllerFactory app.models.timePatterns
  geoip: geoip()
