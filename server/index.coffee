common = require './common'

configure = (app, mongoose) ->
  common.extend app.models, require('./models')(mongoose)
  common.extend app.controllers, require('./controllers')
  common.extend app.middleware, require('./middleware')

module.exports =
  common: common
  mocks: require '../test/server/mocks'
  configure: configure