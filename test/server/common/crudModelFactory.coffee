path = require 'path'
expect = require('chai').expect
assert = require('chai').assert
mocks = require '../mocks'
sinon = mocks.sinon
dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  describe 'CrudModelFactory', ->
    
    crudModelFactory = require dir + '/common/crudModelFactory'

    resource =
      find: -> this
      findOne: -> this
      findByIdAndUpdate: -> this
      modelName: 'bobby'
      sort: -> this
      skip: -> this
      limit: -> this
      exec: -> this
      count: -> this
      create: -> this

    it 'Exports a factory function', (done) ->
      expect(crudModelFactory).to.be.a('function')
      done()

    describe 'Function: (resource) -> { object }', ->
      crud = null

      beforeEach ->
        crud = crudModelFactory resource

      describe 'It outputs an object with properties:', ->
        it 'name: String', ->
          expect(crud).to.have.property 'name'
          expect(crud.name).to.be.a('string')
        
        it 'find: Function', ->
          expect(crud).to.have.property 'find'
          expect(crud.find).to.be.a('function')

        it 'findById: Function', ->
          expect(crud).to.have.property 'findById'
          expect(crud.findById).to.be.a('function')

        it 'findOne: Function', ->
          expect(crud).to.have.property 'findOne'
          expect(crud.findOne).to.be.a('function')

        it 'findOneBy: Function', ->
          expect(crud).to.have.property 'findOneBy'
          expect(crud.findOneBy).to.be.a('function')

        it 'create: Function', ->
          expect(crud).to.have.property 'create'
          expect(crud.create).to.be.a('function')

        it 'update: Function', ->
          expect(crud).to.have.property 'update'
          expect(crud.update).to.be.a('function')

        it 'destroy: Function', ->
          expect(crud).to.have.property 'destroy'
          expect(crud.destroy).to.be.a('function')

        it 'count: Function', ->
          expect(crud).to.have.property 'count'
          expect(crud.count).to.be.a('function')

        describe 'name: String', ->
          it 'exposes resource.modelName as its name', (done) ->
            expect(crud.name).to.equal resource.modelName
            done()

        describe 'find: Function: (options, callback)
        -> callback(err, results, pageCount)', ->

          options = null

          beforeEach (done) ->
            options =
              query:
                bob: 'jack'
                systemId: '124'
            sinon.spy resource, 'find'
            sinon.spy resource, 'sort'
            sinon.spy resource, 'skip'
            sinon.spy resource, 'limit'
            sinon.stub resource, 'count'
            sinon.stub resource, 'exec'

            #this default behaviour for exec and count
            #is overriden in certain tests
            resource.exec.callsArgWith 0, null, []
            resource.count.callsArgWith 1, null, 1

            done()

          afterEach (done) ->
            resource.find.restore()
            resource.sort.restore()
            resource.skip.restore()
            resource.limit.restore()
            resource.count.restore()
            resource.exec.restore()
            done()

          it 'it returns an error if options are not specified', (done) ->
            crud.find null, (err, obj, pageCount) ->
              expect(err).to.equal 'options must be specfied for find'
              expect(obj).to.not.exist
              expect(pageCount).to.equal 0
              done()
          
          it 'it returns an error if options.query is not specified', (done) ->
            options =
              somethingElse:
                bob: 'jack'
        
            crud.find options, (err, obj, pageCount) ->
              expect(err).to.equal 'systemId not specified in query'
              expect(obj).to.not.exist
              expect(pageCount).to.equal 0
              done()
          
          it 'it returns an error if options.query does not specify a systemId'
          , (done) ->
            options =
              query:
                bob: 'jack'
        
            crud.find options, (err, obj, pageCount) ->
              expect(err).to.equal 'systemId not specified in query'
              expect(obj).to.not.exist
              expect(pageCount).to.equal 0
              done()

          it 'it calls resource.find with options.query', (done) ->
            crud.find options, (err, obj, pageCount) ->
              expect(resource.find.calledWith(options.query)).to.be.true
              done()

          it 'it calls resource.sort after calling find', (done) ->
            crud.find options, (err, obj, pageCount) ->
              expect(resource.sort.calledAfter(resource.find)).to.be.true
              done()

          it 'defaults to no sorting', (done) ->
            crud.find options, (err, obj, pageCount) ->
              expect(resource.sort.calledWith({})).to.be.true
              done()

          it 'but will sort with any value specified in options.sort', (done) ->
            options.sort = {bob: "desc"}
            crud.find options, (err, obj, pageCount) ->
              expect(resource.sort.calledWith(options.sort)).to.be.true
              done()

          describe 'pagination', ->
        
            it 'it defaults to asking for page 1', (done) ->
              crud.find options, (err, obj, pageCount) ->
                expect(resource.skip.calledWith(0)).to.be.true
                done()
            
            it 'it defaults to asking for at most 10000 results', (done) ->
              crud.find options, (err, obj, pageCount) ->
                expect(resource.limit.calledWith(10000)).to.be.true
                done()
            
            it 'calls skip after sort', (done) ->
              crud.find options, (err, obj, pageCount) ->
                expect(resource.skip.calledAfter(resource.sort)).to.be.true
                done()

            it 'calls limit after skip', (done) ->
              crud.find options, (err, obj, pageCount) ->
                expect(resource.limit.calledAfter(resource.skip)).to.be.true
                done()

            describe 'example with 30 results, options.page = 3,
            options.max = 10', ->

              beforeEach ->
                resource.count.restore()
                sinon.stub resource, 'count'
                resource.count.callsArgWith 1, null, 30
                options.page = 3
                options.max = 10

              it 'calls skip with 20', (done) ->
                crud.find options, (err, obj, pageCount) ->
                  expect(resource.skip.calledWith(20)).to.be.true
                  done()
                  
              it 'calls limit with 10', (done) ->
                crud.find options, (err, obj, pageCount) ->
                  expect(resource.limit.calledWith(10)).to.be.true
                  done()

              it 'returns pageCount as celing of results / options.max'
              , (done) ->
                crud.find options, (err, obj, pageCount) ->
                  expect(pageCount).to.equal 3
                  done()

          it 'returns an error if the find query fails', (done) ->
            resource.exec.restore()
            sinon.stub resource, 'exec'
            resource.exec.callsArgWith 0, 'error', null, 0

            crud.find options, (err, obj, pageCount) ->
              assert resource.exec.called, "exec not called"
              expect(err).to.equal 'error'
              expect(obj).to.not.exist
              expect(pageCount).to.equal 0
              done()

          it 'reports error if it cannot count the results', (done) ->
            resource.count.restore()
            sinon.stub resource, 'count'
            resource.count.callsArgWith 1, 'some error', 2

            crud.find options, (err, obj, pageCount) ->
              assert resource.exec.called, "exec not called"
              assert resource.count.called, "did not call count"
              expect(err).to.equal 'could not count the results'
              done()

          it 'counts the total number of results in a find', (done) ->
            resource.count.restore()
            sinon.stub resource, 'count'
            resource.count.callsArgWith 1, null, 25
            options.max = 10

            crud.find options, (err, obj, pageCount) ->
              expect(err).to.not.exist
              expect(obj).to.be.an 'array'
              expect(pageCount).to.equal 3

              options.max = 20
              crud.find options, (err, obj, pageCount) ->
                expect(err).to.not.exist
                expect(obj).to.be.an 'array'
                expect(pageCount).to.equal 2
                done()

          it 'returns nothing if that is all you ask for', (done) ->
            options.max = -3
            crud.find options, (err, obj, pageCount) ->
              expect(err).to.not.exist
              expect(obj).to.be.an 'array'
              expect(pageCount).to.equal 0

              options.max = 0
              crud.find options, (err, obj, pageCount) ->
                expect(err).to.not.exist
                expect(obj).to.be.an 'array'
                expect(pageCount).to.equal 0
                assert resource.exec.callCount is 0
                , "exec should not have been called"
                assert resource.find.callCount is 0
                , "find should not have been called"
                done()

        describe 'findOne: (query, callback) -> callback(err, obj)', ->

          beforeEach (done) ->
            sinon.stub resource, 'findOne'
            resource.findOne.callsArgWith(1,null,{bob:"123"})
            done()

          afterEach (done) ->
            resource.findOne.restore()
            done()


          it 'returns an error if systemId not specified on query', (done) ->
            query =
              _id: 'bob'
          
            crud.findOne query, (err, obj) ->
              expect(err).to.equal 'Cannot find ' +
              resource.modelName + ' - no SystemId'
              expect(obj).to.not.exist
              done()
          
          it 'returns and error if no query specified', (done) ->
            crud.findOne null, (err, obj) ->
              expect(err).to.equal 'Cannot find ' + resource.modelName +
              ' - no SystemId'
              expect(obj).to.not.exist
              done()

          it 'returns object if found', (done) ->
            query =
              systemId: 123
              _id: 'bob'

            crud.findOne query, (err, obj) ->
              assert resource.findOne.calledWith(
                {'_id': 'bob', 'systemId': 123}
              ), "findOne not called correctly"
              expect(err).to.not.exist
              expect(obj).to.have.property 'bob', '123'
              done()

          it 'returns any errors from Resource.findOne', (done) ->
            query =
              systemId: 123
              _id: 'bob'

            resource.findOne.restore()
            sinon.stub resource, 'findOne'
            resource.findOne.callsArgWith 1, "an error", null
            
            crud.findOne query, (err, obj) ->
              expect(obj).to.not.exist
              expect(err).to.equal 'an error'
              done()

          it 'returns an error if object not found', (done) ->
            query =
              systemId: 123
              _id: 'bob'

            resource.findOne.restore()
            sinon.stub resource, 'findOne'
            resource.findOne.callsArgWith 1, null, null
            
            crud.findOne query, (err, obj) ->
              expect(obj).to.not.exist
              expect(err).to.equal 'Cannot find ' + resource.modelName
              done()

        describe 'findOneBy: Function', ->
          beforeEach (done) ->
            sinon.spy crud, 'findOne'
            sinon.stub resource, 'findOne'
            resource.findOne.callsArg 1
            done()
          
          afterEach (done) ->
            crud.findOne.reset()
            resource.findOne.restore()
            done()

          it 'forms a query from params and aliases findOne', (done) ->
            crud.findOneBy 'akey', 'a value', 'a systemId', (err, obj) ->
              assert crud.findOne.calledWith(
                {akey: 'a value', systemId: 'a systemId'}, sinon.match.func
              ), 'findOne not passed correct query'
              done()

        describe 'findById: Function(id, systemId, callback)
        -> callback(err, obj)', ->
          beforeEach (done) ->
            sinon.spy crud, 'findOneBy'
            sinon.stub resource, 'findOne'
            resource.findOne.callsArg 1
            done()
          
          afterEach (done) ->
            crud.findOneBy.reset()
            resource.findOne.restore()
            done()

          it 'aliases findOneBy', (done) ->
            crud.findById '123', "systemId", (err, obj) ->
              assert crud.findOneBy.calledWith(
                '_id', '123', "systemId", sinon.match.func
              ), "findOne not called correctly"
              done()

        describe 'create: (json, callback) -> callback(err, obj)', ->
          beforeEach (done) ->
            sinon.stub resource, 'create'
            done()
          
          afterEach (done) ->
            resource.create.restore()
            done()

          it 'returns an error if systemId not specified in json', (done) ->
            json =
              name: 'bob'

            crud.create json, (err, obj) ->
              expect(err).to.equal resource.modelName +
              ' could not be created - no systemId'
              expect(obj).to.not.exist
              done()
          
          it 'passes json through to resource.create', (done) ->
            json =
              some: 'data'
              systemId: '123'

            resource.create.callsArgWith 1, null, {}
            
            crud.create json, (err, obj) ->
              expect(err).to.not.exist
              expect(obj).to.be.an 'object'
              expect(resource.create.called).to.be.true
              expect(resource.create.calledWith(json, sinon.match.func)
              , 'json did not match').to.be.true
              done()
          
          it 'returns the error if create errors', (done) ->
            json =
              some: 'data'
              systemId: '123'

            resource.create.callsArgWith 1, "an error",null

            crud.create json, (err, obj) ->
              expect(err).to.equal 'an error'
              expect(obj).to.not.exist
              done()

          it 'returns the error if create returns nothing', (done) ->
            json =
              some: 'data'
              systemId: '123'

            resource.create.callsArgWith 1, null, null

            crud.create json, (err, obj) ->
              expect(err).to.equal resource.modelName + ' could not be saved'
              expect(obj).to.not.exist
              done()

          it 'retuns the object passed by create if all ok', (done) ->
            json =
              some: 'data'
              systemId: '123'

            resource.create.callsArgWith 1, null, json

            crud.create json, (err, obj) ->
              expect(err).to.not.exist
              expect(obj).to.equal json
              done()

        describe 'update: Function(id, json, callback)
        -> callback(err, obj)', ->
          beforeEach (done) ->
            sinon.stub resource, 'findByIdAndUpdate'
            resource.findByIdAndUpdate.callsArgWith 2, null, {}
            done()

          afterEach (done) ->
            resource.findByIdAndUpdate.restore()
            done()
          
          it 'returns an error if systemId not specified in json', (done) ->
            json =
              _id: 'bob'
          
            crud.update 'bob', json, (err, obj) ->
              expect(err).to.equal resource.modelName +
              ' could not be updated - no systemId'
              expect(obj).to.not.exist
              done()
          
          it 'passes json through to resource.findByIdAndUpdate', (done) ->
            crud.update '123', {some: 'bad json', systemId: '123'}
            , (err, obj) ->
              expect(err).to.not.exist
              expect(obj).to.be.an 'object'
              assert resource.findByIdAndUpdate.calledWith(
                '123', {some: 'bad json', systemId: '123'}, sinon.match.func
              )
              , 'findByIdAndUpdate not called with correct parameters'
              done()

        describe 'destroy: (id, systemId, callback) -> callback(err)', ->
          it 'HAS NO TESTS YET :-(', (done) ->
            done()