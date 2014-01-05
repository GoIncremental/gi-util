assert = require('chai').assert
expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'

counters = require './counters'
timePatterns = require './timePatterns'
resources = require './resources'

module.exports = () ->
  describe 'Models', ->
    stubs = null
    models = null
    mongooseMock = null
    
    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      stubs =
        './counters': sinon.stub().returns {name: 'counters'}
        './timePatterns': sinon.stub().returns {name: 'timePatterns'}
        './resources': sinon.stub().returns {name: 'resources'}

      mongooseMock = sinon.spy()

      models = proxyquire(dir + '/models', stubs)(mongooseMock)

      done()

    describe 'Exports', ->

      it 'counter', (done) ->
        assert.ok stubs['./counters'].calledOnce
        assert stubs['./counters'].calledWithExactly(mongooseMock)
        , 'counters not initalized'
        assert.property models, 'counters', 'models does not export counter'
        expect(models.counters.name).to.equal 'counters'
        done()

      it 'timePatterns', (done) ->
        assert.ok stubs['./timePatterns'].calledOnce
        done()

      it 'resources', (done) ->
        assert.ok stubs['./resources'].calledOnce
        done()
    
      counters()
      timePatterns()
      resources()