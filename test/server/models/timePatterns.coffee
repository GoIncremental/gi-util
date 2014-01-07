path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
mocks = require '../mocks'
proxyquire = require 'proxyquire'

dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'TimePatterns', ->

    modelFactory = require dir + '/models/timePatterns'
    model = null
    expectedDefinition =
      name: 'TimePattern'
      schemaDefinition:
        systemId: 'ObjectId'
        name: 'String'
        pattern: ['Number']
        recurrence: 'String'
        base: 'Date'

    it 'Exports a factory function', (done) ->
      expect(modelFactory).to.be.a('function')
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
      
      it 'Creates a timePatterns schema', (done) ->
        expect(mocks.dal.schemaFactory.calledWithMatch(expectedDefinition))
        .to.be.true
        done()

      it 'Creates a timePatterns model', (done) ->
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

      it 'pattern: [Number]', (done) ->
        expect(schema).to.have.property('pattern').with.length 1
        expect(schema.pattern[0]).to.equal 'Number'
        done()

      it 'recurrence: String', (done) ->
        expect(schema).to.have.property 'recurrence', 'String'
        done()

      it 'base: Date', (done) ->
        expect(schema).to.have.property 'base', 'Date'
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
        mockDal = mocks.dal
        mockDal.crudFactory = mockCrudModelFactory
        model = modelFactory mocks.dal

      mocks.exportsCrudModel 'TimePattern'
      , modelFactory(mocks.dal)
      , {create: true, update: true}

      describe 'Overridden Crud', ->

        describe 'create: function(json, callback)', ->
          beforeEach ->
            sinon.stub mockCrudModel, 'create'
            sinon.stub model, '_checkValidPattern'

          afterEach ->
            mockCrudModel.create.restore()
            model._checkValidPattern.restore()

          it 'calls crud.create with json and callback if no json.pattern'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"

            model.create json, "bob"
            expect(model._checkValidPattern.notCalled).to.be.true
            expect(mockCrudModel.create.calledWith json, "bob").to.be.true
            done()

          it 'calls crud.create with json and callback if no json.recurrence'
          , (done) ->
            json =
              an: "object"
              pattern: "a pattern"

            model.create json, "bob"
            expect(model._checkValidPattern.notCalled).to.be.true
            expect(mockCrudModel.create.calledWith json, "bob").to.be.true
            done()

          it 'calls checkValidPattern if recurrence and pattern are given'
          , (done) ->
            json =
              an: "object"
              pattern: "a pattern"
              recurrence: "a recurrence"

            model._checkValidPattern.returns false
            model.create json, (err, res) ->
              expect(model._checkValidPattern.calledOnce).to.be.true
              done()

          it 'callsback with an error if checkValidPattern returns false'
          , (done) ->
            json =
              an: "object"
              pattern: "a pattern"
              recurrence: "a recurrence"

            model._checkValidPattern.returns false
            model.create json, (err, res) ->
              expect(model._checkValidPattern.calledOnce).to.be.true
              expect(mockCrudModel.create.notCalled).to.be.true
              expect(res).to.not.exist
              expect(err).to.equal "pattern exceeds recurrence"
              done()

          it 'calls crud create with json and callback if checkValidPattern ok'
          , (done) ->
            json =
              an: "object"
              pattern: "a pattern"
              recurrence: "a recurrence"

            model._checkValidPattern.returns true
            model.create json, "bob"
            expect(model._checkValidPattern.calledOnce).to.be.true
            expect(mockCrudModel.create.calledWith json, "bob").to.be.true
            done()
        
        describe 'update: function(id, json, callback)', ->
          beforeEach ->
            sinon.stub mockCrudModel, 'update'
            sinon.stub mockCrudModel, 'findById'
            sinon.stub model, '_checkValidPattern'

          afterEach ->
            mockCrudModel.update.restore()
            mockCrudModel.findById.restore()
            model._checkValidPattern.restore()

          it 'calls crud.update with json and callback if no json.pattern ' +
          'and no json.recurrence', (done) ->
            json =
              an: "object"

            model.update "abc", json, "bob"
            expect(mockCrudModel.findById.notCalled).to.be.true
            expect(mockCrudModel.update.calledWith "abc", json, "bob")
            .to.be.true
            done()


          it 'calls crud.findById if json.pattern given'
          , (done) ->
            json =
              an: "object"
              pattern: "a pattern"
              systemId: "123"

            model.update "abc", json, "bob"
            expect(mockCrudModel.findById.calledOnce).to.be.true
            done()

          it 'calls crud.findById if json.recurrence given'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              systemId: "123"

            model.update "abc", json, "bob"
            expect(mockCrudModel.findById.calledOnce).to.be.true
            done()

          it 'calls crud.findById with id and json.systemId'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              systemId: "123"

            model.update "abc", json, "bob"
            expect(mockCrudModel.findById.calledWith "abc"
            , json.systemId, sinon.match.func).to.be.true
            done()

          it 'calls back with error if findById returns an error', (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              systemId: "123"

            mockCrudModel.findById.callsArgWith 2, "an error", null
            model.update "abc", json, (err, obj) ->
              expect(err).to.equal 'an error'
              expect(obj).to.not.exist
              done()

          it 'calls back with error if findById returns null', (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              systemId: "123"

            mockCrudModel.findById.callsArgWith 2, null, null
            model.update "abc", json, (err, obj) ->
              expect(err).to.equal 'could not find time pattern with id abc'
              expect(obj).to.not.exist
              done()

          it 'calls check valid pattern with json.recurrence and json.pattern'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              pattern: "a pattern"
              systemId: "123"

            obj =
              recurrence: "another recurrence"
              pattern: "another pattern"

            mockCrudModel.findById.callsArgWith 2, null, obj
            model._checkValidPattern.returns true
            
            model.update "abc", json, "bob"

            expect(model._checkValidPattern.calledWith(
              "a recurrence", "a pattern"
            )).to.be.true
            done()

          it 'calls crud update if checkValidPattern returns true'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              pattern: "a pattern"
              systemId: "123"

            obj =
              recurrence: "another recurrence"
              pattern: "another pattern"

            mockCrudModel.findById.callsArgWith 2, null, obj
            model._checkValidPattern.returns true
            
            model.update "abc", json, "bob"

            expect(mockCrudModel.update.calledWith "abc", json, "bob")
            .to.be.true
            done()

          it 'calls back with an error if checkValidPattern returns false'
          , (done) ->
            json =
              an: "object"
              recurrence: "a recurrence"
              pattern: "a pattern"
              systemId: "123"

            obj =
              recurrence: "another recurrence"
              pattern: "another pattern"

            mockCrudModel.findById.callsArgWith 2, null, obj
            model._checkValidPattern.returns false
            
            model.update "abc", json, (err, obj) ->
              expect(mockCrudModel.update.notCalled).to.be.true
              expect(err).to.equal "pattern exceeds recurrence"
              expect(obj).to.not.exist
              done()

      describe 'Other', ->

        stubs = null
        beforeEach ->
          stubs =
            '../common':
              timePatterns:
                timeOnBetween: sinon.stub()
                timeAfterXSecondsOnFrom: sinon.stub()

          model = proxyquire(dir + '/models/timePatterns', stubs)(
            mocks.dal
          )

          sinon.stub mockCrudModel, 'findById'

        afterEach ->
          mockCrudModel.findById.restore()

        describe 'timeOnBetween: function(start, stop, patternId, systemId,' +
        ' callback) -> (err, obj)', ->

          it 'calls crud.findById', (done) ->
            model.timeOnBetween "a", "b", "c", "d", "e"
            expect(mockCrudModel.findById.calledWith("c","d",sinon.match.func))
            .to.be.true
            done()

          it 'callsback with error if findById errors', (done) ->
            mockCrudModel.findById.callsArgWith 2, "an error", {}
            model.timeOnBetween "a", "b", "c", "d", (err, obj) ->
              expect(err).to.equal 'Could not find pattern with id: c'
              done()

          it 'calls back with error if findById finds nothing', (done) ->
            mockCrudModel.findById.callsArgWith 2, null, null
            model.timeOnBetween "a", "b", "c", "d", (err, obj) ->
              expect(err).to.equal 'Could not find pattern with id: c'
              done()

          it 'calls timeOnBetween with start, stop, pattern and recurrence'
          , (done) ->
            obj =
              pattern: "a pattern"
              recurrence: "a recurrence"
            mockCrudModel.findById.callsArgWith 2, null, obj
            model.timeOnBetween "a", "b", "c", "d"
            expect(stubs['../common'].timePatterns.timeOnBetween.calledWith(
              "a", "b", obj.pattern, obj.recurrence
            )).to.be.true

            done()

          it 'returns result and no error if callback given'
          , (done) ->
            obj =
              pattern: "a pattern"
              recurrence: "a recurrence"
            mockCrudModel.findById.callsArgWith 2, null, obj
            stubs['../common'].timePatterns.timeOnBetween.returns "bob"
            model.timeOnBetween "a", "b", "c", "d", (err, result) ->
              expect(err).to.not.exist
              expect(result).to.equal "bob"
              done()

        describe 'timeAfterXSecondsOnFrom: function(start, x, patternId,' +
        ' systemId, callback) -> (err, obj)', ->

          it 'calls crud.findById', (done) ->
            model.timeAfterXSecondsOnFrom "a", "b", "c", "d", "e"
            expect(mockCrudModel.findById.calledWith("c","d",sinon.match.func))
            .to.be.true
            done()

          it 'callsback with error if findById errors', (done) ->
            mockCrudModel.findById.callsArgWith 2, "an error", {}
            model.timeAfterXSecondsOnFrom "a", "b", "c", "d", (err, obj) ->
              expect(err).to.equal 'Could not find pattern with id: c'
              done()

          it 'calls back with error if findById finds nothing', (done) ->
            mockCrudModel.findById.callsArgWith 2, null, null
            model.timeAfterXSecondsOnFrom "a", "b", "c", "d", (err, obj) ->
              expect(err).to.equal 'Could not find pattern with id: c'
              done()

          it 'calls timeAfterXSecondsOnFrom with start, stop, pattern' +
          ' and recurrence', (done) ->
            obj =
              pattern: "a pattern"
              recurrence: "a recurrence"
            mockCrudModel.findById.callsArgWith 2, null, obj
            model.timeAfterXSecondsOnFrom "a", "b", "c", "d"
            expect(stubs['../common'].timePatterns
            .timeAfterXSecondsOnFrom.calledWith(
              "a", "b", obj.pattern, obj.recurrence
            )).to.be.true

            done()

          it 'returns result and no error if callback given'
          , (done) ->
            obj =
              pattern: "a pattern"
              recurrence: "a recurrence"
            mockCrudModel.findById.callsArgWith 2, null, obj
            stubs['../common'].timePatterns
            .timeAfterXSecondsOnFrom.returns "bob"
            model.timeAfterXSecondsOnFrom "a", "b", "c", "d", (err, result) ->
              expect(err).to.not.exist
              expect(result).to.equal "bob"
              done()

    describe 'Private methods', ->
      describe 'checkValidPattern: func(...)', ->
        it 'returns true if recurrence not specified', (done) ->
          expect(model._checkValidPattern null, "pattern").to.be.true
          done()
        it 'returns true if pattern not specified', (done) ->
          expect(model._checkValidPattern "recurrence").to.be.true
          done()

        describe 'recurrence: weekly', ->
          it 'returns true if period sums is <= than sec per week (604800)'
          , (done) ->
            expect(model._checkValidPattern "weekly", [0, 4]).to.be.true
            expect(model._checkValidPattern "weekly", []).to.be.true
            expect(model._checkValidPattern "weekly", [604800]).to.be.true
            done()
          it 'returns false otherwise', (done) ->
            expect(model._checkValidPattern "weekly", [10000000]).to.be.false
            expect(model._checkValidPattern "weekly", [1, 604800]).to.be.false
            expect(model._checkValidPattern "weekly", [604800, 1]).to.be.false
            done()

        describe 'recurrence: monthly', ->
          it 'returns true if period sums is <= than sec per week (2678400)'
          , (done) ->
            expect(model._checkValidPattern "monthly", [0, 4]).to.be.true
            expect(model._checkValidPattern "monthly", []).to.be.true
            expect(model._checkValidPattern "monthly", [2678400]).to.be.true
            done()
          it 'returns false otherwise', (done) ->
            expect(model._checkValidPattern "monthly", [10000000]).to.be.false
            expect(model._checkValidPattern "monthly", [1, 2678400]).to.be.false
            expect(model._checkValidPattern "monthly", [2678400, 1]).to.be.false
            done()

        describe 'recurrence: yearly', ->
          it 'returns true if period sums is <= than sec per week (31536000)'
          , (done) ->
            expect(model._checkValidPattern "yearly", [0, 4]).to.be.true
            expect(model._checkValidPattern "yearly", []).to.be.true
            expect(model._checkValidPattern "yearly", [31536000]).to.be.true
            done()
          it 'returns false otherwise', (done) ->
            expect(model._checkValidPattern "yearly", [100000000]).to.be.false
            expect(model._checkValidPattern "yearly", [1, 31536000]).to.be.false
            expect(model._checkValidPattern "yearly", [31536000, 1]).to.be.false
            done()
