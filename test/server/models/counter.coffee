path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
mocks = require '../mocks'

dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'Counters', ->

    model = require(dir + '/models/counter')

    it 'Exports a factory function', (done) ->
      expect(model).to.be.a('function')
      done()

    describe 'Function: (mongoose) -> { object }', ->
      counter = model mocks.mongoose

      describe 'It outputs an object with properties', ->
        it 'getNext: Function', ->
          expect(counter).to.have.property 'getNext'
          expect(counter.getNext).to.be.a('function')

        describe 'getNext: Function: (name, systemId,
        callback) -> callback(err, counter)', ->
          it 'has no tests yet :-(', (done) ->
            done()