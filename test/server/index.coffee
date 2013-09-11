proxyquire = require 'proxyquire'
path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect

module.exports = ->

  describe 'Exports', ->
    stubs = null
    module = null

    beforeEach (done) ->
      dir =  path.normalize __dirname + '../../../server'

      stubs =
        './common': sinon.stub().returns { extend: -> }

      module = proxyquire dir, stubs

      done()

    it 'common', (done) ->
      expect(module).to.have.property 'common'
      done()
      
    it 'mocks', (done) ->
      expect(module).to.have.property 'mocks'
      done()
    
    it 'configure: function() -> ', (done) ->
      expect(module).to.have.property 'configure'
      done()