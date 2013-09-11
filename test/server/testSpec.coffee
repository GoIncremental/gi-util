index = require './index'
common = require './common'
routes = require './routes'
controllers = require './controllers'
models = require './models'

describe 'gint-util', ->
  index()
  common()
  describe 'configure: function () -> {}', ->
    routes()
    controllers()
    models()