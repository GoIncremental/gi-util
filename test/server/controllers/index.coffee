assert = require('chai').assert
expect = require('chai').expect

sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'

crud = require './crud'
helpers = require './helper'
module.exports = () ->
  describe 'Controllers', ->
    controllers = null
    stubs = null

    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../../server'

      stubs =
        './crud': {crud: "object"}
        './slug': {slug: "object"}

      controllers = proxyquire(dir + '/controllers', stubs)

      done()
    
    describe 'Exports', ->
      it 'exports crud controller', (done) ->
        assert.property controllers, 'crud', 'Controllers does not export crud'
        expect(controllers.crud).to.have.property 'crud', "object"
        done()

      crud()

      it 'exports slug controller', (done) ->
        assert.property controllers, 'slug', 'Controllers does not export slug'
        expect(controllers.slug).to.have.property 'slug', "object"
        done()
    
    describe 'Internal Helpers', ->
      helpers()