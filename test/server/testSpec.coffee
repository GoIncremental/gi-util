index = require './index'
controllers = require './controllers'
models = require './models'

describe 'gint-util', ->
  index()
  controllers()
  models()
