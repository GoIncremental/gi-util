common = require './common'
routes = require './routes'
middleware = require './middleware'
models = require './models'
controllers = require './controllers'
middleware = require './middleware'

configure = (app, dal) ->
  common.extend app.models, models(dal)
  common.extend app.controllers, controllers(app)
  common.extend app.middleware, middleware

  routes.configure app, common.rest

module.exports =
  common: common
  mocks: require '../test/server/mocks'
  configure: configure
  middleware: middleware