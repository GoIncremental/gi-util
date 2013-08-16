assert = require('chai').assert
expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'

counter = require './counter'
crud = require './crud'

module.exports = () ->
  describe 'Models', ->
    stubs = null
    models = null
    mongooseMock = null
    
    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      stubs =
        './crud':
          name: 'crud'
        './counter': sinon.stub().returns {name: 'counter'}

      mongooseMock = sinon.spy()

      models = proxyquire(dir + '/models', stubs)(mongooseMock)

      done()

    describe 'Exports', ->
      it 'crud', (done) ->
        assert.property models, 'crud', 'models does not export crud'
        expect(models.crud.name).to.equal 'crud'
        done()

      it 'counter', (done) ->
        assert.ok stubs['./counter'].calledOnce
        assert stubs['./counter'].calledWithExactly(mongooseMock)
        , 'counter not initalized'
        assert.property models, 'counter', 'models does not export counter'
        expect(models.counter.name).to.equal 'counter'
        done()
    
    crud()
    counter()