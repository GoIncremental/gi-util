assert = require('chai').assert
expect = require('chai').expect

sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'

helpers = require './helper'

module.exports = () ->
  describe 'Controllers', ->
    controllersFactory = null
    crudControllerFactory = null
    stubs = null
    app =
      models:
        timePatterns: 'timePatterns'

    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      crudControllerFactory = sinon.stub().returnsArg 0

      stubs =
        './slug': {slug: "slug object"}
        '../common':
          crudControllerFactory: crudControllerFactory

      controllersFactory = proxyquire(dir + '/controllers', stubs)

      done()
    
    describe 'Exports', ->
      controllers = null
      
      beforeEach ->
        controllers = controllersFactory app

      it 'slug controller', (done) ->
        assert.property controllers, 'slug', 'Controllers does not export slug'
        expect(controllers.slug).to.have.property 'slug', "slug object"
        done()

      it 'timePattern crud controller', (done) ->
        assert crudControllerFactory.calledWith(app.models.timePatterns)
        , 'crud controller factory not called for timePatterns'
        assert.property controllers, 'timePattern'
        , 'Controllers does not export timePattern'
        expect(controllers.timePattern).to.equal app.models.timePatterns
        done()

    describe 'Internal Helpers', ->
      helpers()