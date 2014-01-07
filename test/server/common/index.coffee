assert = require('chai').assert
expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'
globalcommon = require '../../common'
dal = require './dal'
crudModelFactory = require './crudModelFactory'
crudControllerFactory = require './crudControllerFactory'

module.exports = () ->
  describe 'Common', ->
    stubs = null
    common = null
    mongooseMock = null
    
    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      stubs =
        './crudControllerFactory':
          name: 'crudControllerFactory'
        './crudModelFactory':
          name: 'crudModelFactory'
        './rest': 'restStub'
        './dal': 'dalStub'
        '../../common/timePatterns': 'timePatternsStub'

      mongooseMock = sinon.spy()

      common = proxyquire dir + '/common', stubs

      done()

    describe 'Exports', ->
      it 'crudControllerFactory', (done) ->
        assert.property common, 'crudControllerFactory'
        , 'common does not export crudControllerFactory'
        expect(common.crudControllerFactory.name)
        .to.equal 'crudControllerFactory'
        done()

      it 'crudModelFactory', (done) ->
        assert.property common, 'crudModelFactory'
        , 'common does not export crudModelFactory'
        expect(common.crudModelFactory.name).to.equal 'crudModelFactory'
        done()

      it 'extend', (done) ->
        expect(common, 'common does not export extend')
        .to.have.ownProperty 'extend'
        done()

      it 'rest', (done) ->
        expect(common, 'common does not export rest')
        .to.have.ownProperty 'rest'
        expect(common.rest).to.equal 'restStub'
        done()
      
      it 'timePatterns', (done) ->
        expect(common, 'common does not export timePatterns')
        .to.have.ownProperty 'timePatterns'
        expect(common.timePatterns).to.equal 'timePatternsStub'
        done()

      it 'dal', (done) ->
        expect(common, 'common does not export dal')
        .to.have.ownProperty 'dal'
        expect(common.dal).to.equal 'dalStub'
        done()

    crudControllerFactory()

    crudModelFactory()
      
    describe 'extend: (object,properties) -> object', ->
      it 'appends properties onto object', (done) ->
        object =
          alice: '1'

        properties =
          bob: 2
          charlie: ['1', '2', '3']
          david:
            sophie: 'a'
        result = common.extend object, properties
        expect(result).to.have.ownProperty 'alice', '1'
        expect(result).to.have.ownProperty 'bob', 2
        # expect(result).to.have.ownProperty('charlie').with.length 3
        expect(result).to.have.ownProperty 'david'
        expect(result.david).to.have.ownProperty 'sophie', 'a'
        done()

    globalcommon()
    
    dal()