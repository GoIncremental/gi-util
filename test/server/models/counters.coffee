path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
mocks = require '../mocks'

dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'Counters', ->

    modelFactory = require(dir + '/models/counters')
    model = null

    expectedDefinition =
      name: 'Counters'
      schemaDefinition:
        name: 'String'
        number: 'Number'

    it 'Exports a factory function', (done) ->
      expect(modelFactory).to.be.a 'function'
      done()

    describe 'Constructor: (dal) -> { object }', ->
      beforeEach (done) ->
        sinon.spy mocks.dal, 'schemaFactory'
        sinon.spy mocks.dal, 'modelFactory'
        model = modelFactory mocks.dal
        done()
      
      afterEach ->
        mocks.dal.modelFactory.restore()
        mocks.dal.schemaFactory.restore()

      it 'Creates a resources schema', (done) ->
        expect(mocks.dal.schemaFactory.calledWithMatch(expectedDefinition))
        .to.be.true
        done()

      it 'Creates a resources model', (done) ->
        returnedDefinition = mocks.dal.schemaFactory.returnValues[0]
        expect(mocks.dal.modelFactory.calledWithMatch(expectedDefinition))
        .to.be.true
        done()

    describe 'Schema', ->
      schema = null
      beforeEach ->
        sinon.spy mocks.dal, 'schemaFactory'
        model = modelFactory mocks.dal
        schema = mocks.dal.schemaFactory.returnValues[0]

      afterEach ->
        mocks.dal.schemaFactory.restore()

      it 'systemId: ObjectId', (done) ->
        expect(schema).to.have.property 'systemId', 'ObjectId'
        done()

      it 'name: String', (done) ->
        expect(schema).to.have.property 'name', 'String'
        done()

      it 'number: Number', (done) ->
        expect(schema).to.have.property 'number', 'Number'
        done()

    describe 'Exports', ->
      mockModel =
        findOneAndUpdate: ->

      mockModelFactory = () ->
        mockModel

      beforeEach ->
        mocks.dal.modelFactory = mockModelFactory
        model = modelFactory mocks.dal
          
      describe 'Other', ->
        beforeEach ->
          sinon.stub mockModel, 'findOneAndUpdate'

        afterEach ->
          mockModel.findOneAndUpdate.restore()

        describe 'getNext: (name, systemId, callback)' +
        ' -> (err, obj)', ->
          it 'looks for an object with the name and systemId in counters'
          , (done) ->
            model.getNext "aName", "aSysId", "cb"

            expect(mockModel.findOneAndUpdate.calledWith(
              {name: "aName", systemId: "aSysId"}
            ), 'getNext does not look for existing counter').to.be.true
            done()

          it 'increments the number by one', (done) ->
            model.getNext "aName", "aSysId", "cb"

            expect(mockModel.findOneAndUpdate.calledWith(
              sinon.match.any
              , {$inc: {number: 1}}
            ), 'getNext does not increment counter').to.be.true
            done()

          it 'creates a record if none found', (done) ->
            model.getNext "aName", "aSysId", "cb"

            expect(mockModel.findOneAndUpdate.calledWith(
              sinon.match.any
              , sinon.match.any
              , {upsert: true}
            ), 'getNext does not increment counter').to.be.true
            done()

          it 'calls back with error if the update errors', (done) ->
            mockModel.findOneAndUpdate.callsArgWith(3, "an error", null)
            model.getNext "aName", "aSysId", (err, res) ->
              expect(err).to.equal "error"
              expect(res).to.not.exist
              done()

          it 'copes fine if the callback is not given', (done) ->
            mockModel.findOneAndUpdate.callsArgWith(3, "an error", null)
            mockModel.findOneAndUpdate.callsArgWith(3, null, 3)
            model.getNext "a", "b"
            model.getNext "c", "d"
            done()

          it 'returns the number field if all ok', (done) ->
            mockModel.findOneAndUpdate.callsArgWith(3, null, {number: 4})
            model.getNext "aName", "aSysId", (err, res) ->
              expect(err).to.not.exist
              expect(res).to.equal 4
              done()