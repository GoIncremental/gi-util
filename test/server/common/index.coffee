assert = require('chai').assert
expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'
globalcommon = require '../../common'
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

      crudControllerFactory()

      it 'crudModelFactory', (done) ->
        assert.property common, 'crudModelFactory'
        , 'common does not export crudModelFactory'
        expect(common.crudModelFactory.name).to.equal 'crudModelFactory'
        done()

      crudModelFactory()
      globalcommon()