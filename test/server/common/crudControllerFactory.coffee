path = require 'path'
sinon = require 'sinon'
assert = require 'assert'
assert = require('chai').assert
expect = require('chai').expect
mocks = require '../mocks'
proxyquire = require 'proxyquire'

dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'CrudControllerFactory', ->
    
    stubs =
      '../controllers/helper':
        getOptions: ->

    crudControllerFactory = proxyquire dir +
    '/common/crudControllerFactory', stubs

    it 'Exports a factory function', (done) ->
      expect(crudControllerFactory).to.be.a 'function'
      done()

    describe 'Function: (model) -> { object } ', ->
      
      mockModel =
        name: "mockModel"
        create: ->
        update: ->
        destroy: ->
        findById: ->
        find: ->
        count: ->
      
      controller = null
      alice = null
      bob = null
      charlie = null

      beforeEach ->
        alice = {alice: 'alice'}
        bob = {bob: 'bob'}
        charlie = {charlie: 'charlie'}
        controller = crudControllerFactory mockModel

      describe 'returns an object with properties:', ->
        it 'name: String', (done) ->
          expect(controller).to.have.ownProperty 'name'
          expect(controller.name).to.be.a 'string'
          done()
        
        it 'index: Function', (done) ->
          expect(controller).to.have.ownProperty 'index'
          expect(controller.index).to.be.a 'function'
          done()

        it 'create: Function', (done) ->
          expect(controller).to.have.ownProperty 'create'
          expect(controller.create).to.be.a 'function'
          done()

        it 'show: Function', (done) ->
          expect(controller).to.have.ownProperty 'show'
          expect(controller.show).to.be.a 'function'
          done()

        it 'update: Function', (done) ->
          expect(controller).to.have.ownProperty 'update'
          expect(controller.update).to.be.a 'function'
          done()

        it 'destroy: Function', (done) ->
          expect(controller).to.have.ownProperty 'destroy'
          expect(controller.destroy).to.be.a 'function'
          done()

        it 'count: Function', (done) ->
          expect(controller).to.have.ownProperty 'count'
          expect(controller.count).to.be.a 'function'
          done()

        describe 'name: String', ->
          it 'exposes model.name as its name', (done) ->
            expect(controller.name).to.equal mockModel.name
            done()
        
        describe 'index: Function: (req, res, next) -> next() or res.json', ->
          req =
            any: 'thing'
            systemId: '123'
            body: {}

          res =
            json: ->
          
          options =
            some: 'options'

          beforeEach () ->
            sinon.stub mockModel, 'find'
            sinon.stub stubs['../controllers/helper'], 'getOptions'
            stubs['../controllers/helper'].getOptions.returns options
            res.json = sinon.spy()

          afterEach () ->
            mockModel.find.restore()
            res.json.reset()
            stubs['../controllers/helper'].getOptions.restore()

          it 'gets options by passing req and model to helper.getOptions'
          , (done) ->
            mockModel.find.callsArg 1

            controller.index req, {}, () ->
              assert(
                stubs['../controllers/helper'].getOptions.calledWith(
                  req, mockModel
                ), 'did not call helper.getOptions with req and /or model'
              )
              done()

          it 'uses the options returned as the argument for model.find'
          , (done) ->
            mockModel.find.callsArg 1

            controller.index req, {}, () ->
              assert mockModel.find.calledWith(options)
              , 'options not passed to model.find'
              done()

          it 'returns 404 code and the error if model.find returns an error'
          , (done) ->
            mockModel.find.callsArgWith 1, "an error", null, 0

            controller.index req, res
            assert res.json.calledWith(404, "an error")
            , 'res.json did not 404 an error finding'
            done()

          it 'populates res.giResult with the result if next() is given'
          , (done) ->
            mockModel.find.callsArgWith 1, null, {a: 'result'}, 1

            controller.index req, res, () ->
              expect(res.giResult).to.deep.equal {a: 'result'}
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            mockModel.find.callsArgWith 1, null, {a: 'result'}, 1
            controller.index req, res
            assert res.json.calledWith(200, {a: 'result'})
            , 'res.json not called with 200 code and/or result'
            done()

        describe 'create: Function: (req, res, next) -> next() or res.json', ->
          req = null

          res =
            json: ->

          beforeEach () ->
            req =
              any: 'thing'
              systemId: '123'
              body: {}
            
            sinon.stub mockModel, 'create'
            res.json = sinon.spy()

          afterEach () ->
            mockModel.create.restore()
            res.json.reset()

          it 'checks to see if body is an array', (done) ->
            req.body = []
            controller.create req, res, () ->
              expect(res.giResult).to.be.an 'array'
              expect(res.giResult.length).to.equal 0
            done()

          it 'calls model create once for each object', (done) ->
            req.body = [alice, bob]
            mockModel.create.callsArgWith 1, null, null
            controller.create req, res
            expect(mockModel.create.calledTwice).to.be.true
            done()

          it 'returns error messages for any failed objects ' +
          'together with sucess results', (done) ->
            req.body = [alice, bob, charlie]

            mockModel.create.callsArgWith 1, "an error", null
            mockModel.create.callsArgWith 1, null, bob
            mockModel.create.callsArgWith 1, null, null

            controller.create req, res

            expect(res.json.calledWith 500).to.be.true
            expect(res.json.getCall(0).args[1]).to.deep.equal [
              {message: "an error", obj: alice},
              {message: "create failed for reasons unknown", obj: charlie},
              {message: "ok", obj: bob}
            ]

            done()

          it 'sets res.giResult if all sucessfully inserted', (done) ->

            req.body = [alice, bob, charlie]

            mockModel.create.callsArgWith 1, null, alice
            mockModel.create.callsArgWith 1, null, bob
            mockModel.create.callsArgWith 1, null, charlie

            controller.create req, res, () ->
              expect(res.json.called).to.be.false
              expect(res.giResult).to.deep.equal [
                {message: "ok", obj: alice},
                {message: "ok", obj: bob},
                {message: "ok", obj: charlie}
              ]

              done()

          it 'sets res.giResultCode to 200 if sucessful', (done) ->
            req.body = [alice, bob, charlie]

            mockModel.create.callsArgWith 1, null, alice
            mockModel.create.callsArgWith 1, null, bob
            mockModel.create.callsArgWith 1, null, charlie

            controller.create req, res, () ->
              expect(res.json.called).to.be.false
              expect(res.giResultCode).to.equal 200
              done()

          it 'sets res.giResultCode to 500 if there are errors', (done) ->
            req.body = [alice, bob, charlie]

            mockModel.create.callsArgWith 1, null, alice
            mockModel.create.callsArgWith 1, "an error", bob
            mockModel.create.callsArgWith 1, null, charlie

            controller.create req, res, () ->
              expect(res.json.called).to.be.false
              expect(res.giResultCode).to.equal 500
              done()
            
          it 'calls res.json with 200 if no callback specified', (done) ->
            alice = {alice: 'alice'}
            bob = {bob: 'bob'}
            charlie = {charlie: 'charlie'}
            req.body = [alice, bob, charlie]

            mockModel.create.callsArgWith 1, null, alice
            mockModel.create.callsArgWith 1, null, bob
            mockModel.create.callsArgWith 1, null, charlie

            controller.create req, res

            expect(res.json.calledWith 200).to.be.true
            expect(res.json.getCall(0).args[1]).to.deep.equal [
              {message: "ok", obj: alice},
              {message: "ok", obj: bob},
              {message: "ok", obj: charlie}
            ]

            done()

          it 'sets req.body.systemId to the value given in req.systemId'
          , (done) ->
            mockModel.create.callsArgWith 1, null, null
            expect(req.body.systemId).to.not.exist
            controller.create req, res
            expect(req.body.systemId).to.equal req.systemId
            done()

          it 'uses req.body as the first arg for model.create', (done) ->
            mockModel.create.callsArgWith 1
            req.body =
              bob: 'bob'

            expected =
              bob: 'bob'
              systemId: req.systemId

            controller.create req, res
            assert mockModel.create.calledWith(req.body)
            , 'req.body not passed to model.create'
            
            done()

          it 'returns 500 code and the error if model.create returns an error'
          , (done) ->
            mockModel.create.callsArgWith 1, "an error", null

            controller.create req, res
            assert res.json.calledWith(500, {error: "an error"})
            , 'res.json did not 500 an error creating'
            done()

          it 'populates res.giResult with the result if next() is given'
          , (done) ->
            mockModel.create.callsArgWith 1, null, {a: 'result'}

            controller.create req, res, () ->
              expect(res.giResult).to.deep.equal {a: 'result'}
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            mockModel.create.callsArgWith 1, null, {a: 'result'}
            controller.create req, res
            assert res.json.calledWith(200, {a: 'result'})
            , 'res.json not called with 200 code and/or result'
            done()

        describe 'show: Function: (req, res, next) -> next() or res.json', ->
          req = null

          res =
            json: ->

          beforeEach () ->
            req =
              any: 'thing'
              systemId: '123'
              body: {}
            
            sinon.stub mockModel, 'findById'
            res.json = sinon.spy()

          afterEach () ->
            mockModel.findById.restore()
            res.json.reset()

          it 'returns 404 if req.params missing', (done) ->
            controller.show req, res
            assert res.json.calledWith(404)
            , '404 not returned when req.params missing'
            done()

          it 'returns 404 if req.systemId missing', (done) ->
            req.params =
              some: 'thing'
            controller.show req, res
            assert res.json.calledWith(404)
            , '404 not returned when req.params.id missing'
            done()

          it 'returns 404 if req.params.id missing', (done) ->
            req.params =
              id: 'anId'

            delete req.systemId
            controller.show req, res
            assert res.json.calledWith(404)
            , '404 not returned when req.systemId missing'
            done()
          
          it 'passes req.params.id to model.findById as first argument'
          , (done) ->
            req.params =
              id: 'anId'
            controller.show req, res
            assert mockModel.findById.calledWith(req.params.id)
            , 'req.params.id not passed to findById'
            done()

          it 'passes req.systemId to model.findById as second argument'
          , (done) ->
            req.params =
              id: 'anId'
            controller.show req, res
            assert mockModel.findById.calledWith(sinon.match.any, req.systemId)
            , 'req.systemId not passed to findbyId'
            done()

          it 'returns 404 if model.findById returns an error', (done) ->
            req.params =
              id: 'anId'
            mockModel.findById.callsArgWith 2, "an error", null
            controller.show req, res
            assert res.json.calledWith(404)
            , '404 not returned when findbyId errors'
            done()

          it 'returns 404 if model.findById returns no object', (done) ->
            req.params =
              id: 'anId'
            mockModel.findById.callsArgWith 2, null, null
            controller.show req, res
            assert res.json.calledWith(404)
            , '404 not returned when findbyId returns no object'
            done()

          it 'sets res.giResult with result and calls next if next given'
          , (done) ->
            req.params =
              id: 'anId'
            mockModel.findById.callsArgWith 2, null, {a: 'result'}

            controller.show req, res, () ->
              expect(res.giResult).to.deep.equal {a: 'result'}
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            req.params =
              id: 'anId'
            mockModel.findById.callsArgWith 2, null, {a: 'result'}

            controller.show req, res
            assert res.json.calledWith(200, {a: 'result'})
            , 'res.json not called with 200 code and/or result'
            done()

        describe 'update: Function: (req, res, next) -> next() or res.json', ->
          req = null

          res =
            json: ->

          beforeEach () ->
            req =
              any: 'thing'
              systemId: '123'
              body: {}
            
            sinon.stub mockModel, 'update'
            res.json = sinon.spy()

          afterEach () ->
            mockModel.update.restore()
            res.json.reset()
          
          it 'returns 400 if req.params missing', (done) ->
            controller.update  req, res
            assert res.json.calledWith(400)
            , '400 not returned when req.params missing'
            done()

          it 'returns 400 if req.params.id missing', (done) ->
            req.params =
              bob: 'bob'
            controller.update  req, res
            assert res.json.calledWith(400)
            , '400 not returned when req.params.id missing'
            done()
          
          it 'returns 400 if if req.systemId is missing', (done) ->
            req.params =
              id: 'bob'
            delete req.systemId

            controller.update req, res

            assert res.json.calledWith(400)
            , '400 not returne when req.systemId is missing'
            done()
          
          it 'sets req.body.systemId to the value given in req.systemId'
          , (done) ->
            req.params =
              id: 'bob'
            expect(req.body.systemId).to.not.exist
            controller.update req, res
            expect(req.body.systemId).to.equal req.systemId
            done()

          it 'removes _id if it is set on req.body', (done) ->
            req.params =
              id: 'bob'
            
            req.body._id = 'bob'

            controller.update req, res

            payload = mockModel.update.getCall(0).args[1]
            expect(payload).to.not.have.property '_id'
            done()

          it 'passes req.params.id to model.update as first argument'
          , (done) ->
            req.params =
              id: 'anId'
            controller.update req, res
            assert mockModel.update.calledWith(req.params.id)
            , 'req.params.id not passed to update'
            done()

          it 'passes req.body as the second arg for model.update', (done) ->
            req.params =
              id: 'anId'
            req.body =
              bob: 'bob'
              _id: 'will be removed'

            expected =
              bob: 'bob'
              systemId: req.systemId

            controller.update req, res
            assert mockModel.update.calledWith(sinon.match.any, expected)
            , 'req.body not passed to model.update'
            
            done()
          
          it 'returns 404 if model.update returns an error', (done) ->
            req.params =
              id: 'anId'
            mockModel.update.callsArgWith 2, "an error", null
            controller.update req, res
            assert res.json.calledWith(400, {message: "an error"})
            , '400 not returned with error message when update errors'
            done()

          it 'returns 200 if model.update returns no object', (done) ->
            req.params =
              id: 'anId'
            mockModel.update.callsArgWith 2, null, null
            controller.update req, res
            assert res.json.calledWith(200)
            , '404 not returned when update returns no object'
            done()

          it 'sets res.giResult with obj and calls next if next given'
          , (done) ->
            req.params =
              id: 'anId'
            mockModel.update.callsArgWith 2, null, {a: 'obj'}

            controller.update req, res, () ->
              expect(res.giResult).to.deep.equal {a: 'obj'}
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            req.params =
              id: 'anId'
            mockModel.update.callsArgWith 2, null, {a: 'obj'}

            controller.update req, res
            assert res.json.calledWith(200, {a: 'obj'})
            , 'res.json not called with 200 code and/or result'
            done()

        describe 'destroy: Function: (req, res, next) -> next() or res.json', ->
          req = null

          res =
            json: ->

          beforeEach () ->
            req =
              any: 'thing'
              systemId: '123'
              body: {}
            
            sinon.stub mockModel, 'destroy'
            res.json = sinon.spy()

          afterEach () ->
            mockModel.destroy.restore()
            res.json.reset()

          it 'returns 404 if req.params missing', (done) ->
            controller.destroy  req, res
            assert res.json.calledWith(404)
            , '404 not returned when req.params missing'
            done()

          it 'returns 404 if req.params.id missing', (done) ->
            req.params =
              bob: 'bob'
            controller.destroy  req, res
            assert res.json.calledWith(404)
            , '404 not returned when req.params.id missing'
            done()
          
          it 'returns 404 if if req.systemId is missing'
          , (done) ->
            req.params =
              id: 'bob'

            delete req.systemId

            controller.destroy req, res

            assert res.json.calledWith(404)
            , '404 not returned when req.systemId is missing'
            done()
          
          it 'passes req.params.id to model.destroy as first argument'
          , (done) ->
            req.params =
              id: 'anId'
            controller.destroy req, res
            assert mockModel.destroy.calledWith(req.params.id)
            , 'req.params.id not passed to model.destroy'
            done()

          it 'passes req.systemId to model.destroy as second argument'
          , (done) ->
            req.params =
              id: 'anId'
            controller.destroy req, res
            assert mockModel.destroy.calledWith(sinon.match.any, req.systemId)
            , 'req.systemId not passed to model.destroy'
            done()
  
          it 'returns 400 if model.destroy returns an error', (done) ->
            req.params =
              id: 'anId'
            mockModel.destroy.callsArgWith 2, "an error"
            controller.destroy req, res
            assert res.json.calledWith(400, {message: "an error"})
            , '400 not returned with error message when destroy errors'
            done()

          it 'sets res.giResult to Ok and calls next if next given'
          , (done) ->
            req.params =
              id: 'anId'

            mockModel.destroy.callsArgWith 2, null

            controller.destroy req, res, () ->
              expect(res.giResult).to.equal 'Ok'
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            req.params =
              id: 'anId'

            mockModel.destroy.callsArgWith 2, null

            controller.destroy req, res
            assert res.json.calledWith(200)
            , 'res.json not called with 200 code'
            done()

        describe 'count: Function: (req, res, next) -> next() or res.json', ->
          req =
            any: 'thing'
            systemId: '123'
            body: {}

          res =
            json: ->
          
          options =
            query:
              some: 'query'

          beforeEach () ->
            sinon.stub mockModel, 'count'
            sinon.stub stubs['../controllers/helper'], 'getOptions'
            stubs['../controllers/helper'].getOptions.returns options
            res.json = sinon.spy()

          afterEach () ->
            mockModel.count.restore()
            res.json.reset()
            stubs['../controllers/helper'].getOptions.restore()

          it 'gets options by passing req to helper.getOptions', (done) ->
            mockModel.count.callsArg 1

            controller.count req, {}, () ->
              assert stubs['../controllers/helper'].getOptions.calledWith(
                req, mockModel
              ), 'did not call helper.getOptions with req and/or model'
              done()

          it 'uses the options.query returned as the argument for model.count'
          , (done) ->
            mockModel.count.callsArg 1

            controller.count req, {}, () ->
              assert mockModel.count.calledWith(options.query)
              , 'options.query not passed to model.count'
              done()
          
          it 'returns 404 and the error if model.count returns an error'
          , (done) ->
            mockModel.count.callsArgWith 1, "an error"
            controller.count req, res
            assert res.json.calledWith(404, {message: "an error"})
            , '404 not returned with error message when destroy errors'
            done()

          it 'sets res.giResult to count:result and calls next if next given'
          , (done) ->
            mockModel.count.callsArgWith 1, null, 15

            controller.count req, res, () ->
              expect(res.giResult).to.deep.equal {count: 15}
              done()

          it 'returns 200 code and the results if next() not given', (done) ->
            req.params =
              id: 'anId'

            mockModel.count.callsArgWith 1, null, 16

            controller.count req, res
            assert res.json.calledWith(200, 16)
            , 'res.json not called with 200 code and/or correct result'
            done()