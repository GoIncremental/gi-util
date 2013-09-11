assert = require('chai').assert
expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'

counter = require './counter'
timePatterns = require './timePatterns'

module.exports = () ->
  describe 'Models', ->
    stubs = null
    models = null
    mongooseMock = null
    
    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      stubs =
        './counter': sinon.stub().returns {name: 'counter'}
        './timePatterns': sinon.stub().returns {name: 'timePatterns'}

      mongooseMock = sinon.spy()

      models = proxyquire(dir + '/models', stubs)(mongooseMock)

      done()

    describe 'Exports', ->

      it 'counter', (done) ->
        assert.ok stubs['./counter'].calledOnce
        assert stubs['./counter'].calledWithExactly(mongooseMock)
        , 'counter not initalized'
        assert.property models, 'counter', 'models does not export counter'
        expect(models.counter.name).to.equal 'counter'
        done()

      it 'timePatterns', (done) ->
        assert.ok stubs['./timePatterns'].calledOnce
        done()
    
      counter()
      timePatterns()