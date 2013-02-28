should = require 'should'
mongoose = require 'mongoose'
models = require './models'

dropCountersCollection = () ->
  mongoose.connection.collections['counters']?.drop()

describe 'Counter Model', ->

  before (done) ->
    dropCountersCollection()
    done()

  it 'Can intialize a counter', (done) ->
    models.counter.getNext mongoose, mongoose.model('dummy'), (err, res) ->
      should.not.exist.err
      res.should.equal 1
      done()

  it 'Can increment a counter', (done) ->
    models.counter.getNext mongoose, mongoose.model('dummy'), (err, res) ->
      should.not.exist.err
      res.should.equal 2
      done()
