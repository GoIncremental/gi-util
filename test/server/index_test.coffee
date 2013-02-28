should = require 'should'
mongoose = require 'mongoose'
path = require 'path'

dir =  path.normalize __dirname + '../../../..'
index = require dir + '/server'

describe 'NPM Module Exports', ->

  it 'exports models', (done) ->
    should.exist index.models
    done()

  it 'exports controllers', (done) ->
    should.exist index.controllers
    done()