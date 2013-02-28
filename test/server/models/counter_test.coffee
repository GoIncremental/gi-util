should = require 'should'
mongoose = require 'mongoose'
models = require './models'

dropCountersCollection = () ->
  mongoose.connection.collections['counters']?.drop()

describe 'Counter Model', ->
  counter = models.counter
  id = ''
  before (done) ->
    dropCountersCollection()
    done()

  it 'Can intialize a counter', (done) ->
    counter.getNext 'bob', (err, res) ->
      should.not.exist.err
      res.should.equal 1
      done()

  it 'Can increment a counter', (done) ->
    counter.getNext 'bob', (err, res) ->
      should.not.exist.err
      res.should.equal 2
      done()

  it 'Bubbles up errors from mongoose', (done) ->
    done()
