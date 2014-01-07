path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
mocks = require '../mocks'
proxyquire = require 'proxyquire'

dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'Resources', ->
    modelFactory = require dir + '/models/resources'
    model = null

    expectedDefinition =
      name: 'Resource'
      schemaDefinition:
        systemId: 'ObjectId'
        name: 'String'
    
    it 'Exports a factory function', (done) ->
      expect(modelFactory).to.be.a 'function'
      done()

    describe 'Constructor: (dal) -> { object }', ->
      beforeEach ->
        sinon.spy mocks.dal, 'schemaFactory'
        sinon.spy mocks.dal, 'modelFactory'
        sinon.spy mocks.dal, 'crudFactory'
        model = modelFactory mocks.dal

      afterEach ->
        mocks.dal.modelFactory.restore()
        mocks.dal.schemaFactory.restore()
        mocks.dal.crudFactory.restore()

      it 'Creates a resources schema', (done) ->
        expect(mocks.dal.schemaFactory.calledWithMatch(expectedDefinition))
        .to.be.true
        done()

      it 'Creates a resources model', (done) ->
        returnedDefinition = mocks.dal.schemaFactory.returnValues[0]
        expect(mocks.dal.modelFactory.calledWithMatch(expectedDefinition))
        .to.be.true
        done()

      it 'Uses Crud Factory with returned model', (done) ->
        returnedModel = mocks.dal.modelFactory.returnValues[0]
        expect(mocks.dal.crudFactory.calledWithMatch(returnedModel))
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

    describe 'Exports', ->
      mockCrudModel =
        name: "mockModel"
        create: ->
        update: ->
        destroy: ->
        findById: ->
        findOne: ->
        findOneBy: ->
        find: ->
        count: ->

      mockCrudModelFactory = () ->
        mockCrudModel

      beforeEach ->
        mocks.dal.crudFactory = mockCrudModelFactory
        model = modelFactory mocks.dal

      mocks.exportsCrudModel 'Resource'
      , modelFactory(mocks.dal)

      describe 'Other', ->

        stubs = null
        beforeEach ->
          stubs = {}

          model = proxyquire(dir + '/models/resources', stubs)(
            mocks.dal
          )

          sinon.stub mockCrudModel, 'update'

        afterEach ->
          mockCrudModel.update.restore()

        describe 'registerTypes: function(systemId, models, callback)' +
        ' -> (err, obj)', ->

          it 'calls crud.update with a resource type for each model', (done) ->
            models =
              "model1":
                name: "model1 name"
              "model2":
                name: "model2 name"

            expectedType1 =
              systemId: 'a'
              name: 'model1 name'
            expectedType2 =
              systemId: 'a'
              name: 'model2 name'

            model.registerTypes "a", models, "c"

            expect(mockCrudModel.update.calledWith(
              expectedType1,expectedType1,{upsert: true}, "c")
            ).to.be.true

            expect(mockCrudModel.update.calledWith(
              expectedType2,expectedType2,{upsert: true}, "c")
            ).to.be.true
            done()

