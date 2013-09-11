common = require './common'
routes = require './routes'

configure = (app, mongoose) ->
  common.extend app.models, require('./models')(mongoose)
  common.extend app.controllers, require('./controllers')(app)
  common.extend app.middleware, require('./middleware')

  routes.configure app, common.rest

module.exports =
  common: common
  mocks: require '../test/server/mocks'
  configure: configure