path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
proxyquire = require 'proxyquire'

dir =  path.normalize __dirname + '../../../../../server'

module.exports = () ->
  describe 'mongo', ->
    mongo = null
    mongooseStub =
      connect: ->
      connection:
        on: ->
      model: ->
      Schema: ->

    stubs =
      'mongoose': mongooseStub
      'mongoose-long': sinon.spy()
      '../crudModelFactory': 'crudModelFactoryStub'

    beforeEach ->
      mongo = proxyquire(dir + '/common/dal/mongo', stubs)

    it 'requires mongoose-long', (done) ->
      expect(stubs['mongoose-long'].calledWith(mongooseStub)).to.be.true
      done()

    describe 'Exports', ->
      it 'connect', (done) ->
        expect(mongo).to.have.ownProperty 'connect'
        expect(mongo.connect).to.be.a 'function'
        done()

      it 'crudFactory', (done) ->
        expect(mongo).to.have.ownProperty 'crudFactory'
        done()

      it 'modelFactory', (done) ->
        expect(mongo).to.have.ownProperty 'modelFactory'
        done()

      it 'schemaFactory', (done) ->
        expect(mongo).to.have.ownProperty 'schemaFactory'
        done()

      describe 'connect (conf) -> void', ->
        conf =
          name: 'somedb'
          host: 'someHost'
          port: 123
          username: 'user'
          password: 'password'

        beforeEach ->
          sinon.stub mongooseStub, 'connect'
  
        afterEach ->
          mongooseStub.connect.restore()

        it 'connects server given in conf.host', (done) ->
          mongo.connect conf
          expect(mongooseStub.connect.calledWith(conf.host)
          , 'connected to wrong host').to.be.true
          done()
        
        it 'connects to db given in conf.name', (done) ->
          mongo.connect conf
          expect(mongooseStub.connect.calledWith(
            sinon.match.any, conf.name
          ), 'connected to wrong db').to.be.true
          done()

        it 'connects to port given in conf.port', (done) ->
          mongo.connect conf
          expect(mongooseStub.connect.calledWith(
            sinon.match.any, sinon.match.any, conf.port
          ), 'connected to wrong port').to.be.true
          done()

        it 'passes username and password as options', (done) ->
          opts =
            user: conf.username
            pass: conf.password
          
          mongo.connect conf
          expect(mongooseStub.connect.calledWith(
            sinon.match.any, sinon.match.any, sinon.match.any, opts
          ), 'did not pass login credentials').to.be.true
          done()

        it 'returns nothing', (done) ->
          mongooseStub.connect.returns 'a connection object'
          res = mongo.connect conf
          expect(res).to.not.exist
          done()

      describe 'crudFactory', ->
        it 'returns the common.crudModelFactory', (done) ->
          expect(mongo.crudFactory).to.equal 'crudModelFactoryStub'
          done()

      describe 'modelFactory (def) -> model', ->
        def = {}

        beforeEach ->
          def =
            name: 'a model'
            schema: 'a schema'
          sinon.stub mongooseStub, 'model'
        
        afterEach ->
          mongooseStub.model.restore()

        it 'configures mongoose model using def.name'
        , (done) ->
          mongo.modelFactory def
          expect(mongooseStub.model.calledWith(def.name)
          , 'mongoose model created with wrong name').to.be.true
          done()

        it 'configures mongoose model using def.schema'
        , (done) ->
          mongo.modelFactory def
          expect(mongooseStub.model.calledWithExactly(def.name, def.schema)
          , 'mongoose model created with wrong schema').to.be.true
          done()

        it 'overrides collection name with def.options.collectionName'
        , (done) ->
          def.options =
            collectionName: 'bob'

          mongo.modelFactory def
          expect(mongooseStub.model.calledWithExactly(
            def.name, def.schema, 'bob'
          ), 'mongoose model created with wrong collectionName').to.be.true
          done()

        it 'returns the mongoose model', (done) ->
          mongooseStub.model.returns 'a mongoose model'
          res = mongo.modelFactory def
          expect(res).to.equal 'a mongoose model'
          def.options =
            collectionName: 'jack'
          res2 = mongo.modelFactory def
          expect(res2).to.equal 'a mongoose model'
          done()

      describe 'schemaFactory (def) -> schema', ->
        def = {}

        beforeEach ->
          def =
            name: 'a model'
            schemaDefinition: 'a defintion'

          sinon.stub mongooseStub, 'Schema'
          mongooseStub.Schema.returns {a: 'mongoose schema stub'}

        afterEach ->
          mongooseStub.Schema.restore()

        it 'returns new Schema with given definition', (done) ->

          res = mongo.schemaFactory def
          expect(mongooseStub.Schema.calledOnce
          , 'schema not called exactly once').to.be.true
          expect(mongooseStub.Schema.calledWithNew()
          , 'schema not called with new').to.be.true
          expect(mongooseStub.Schema.calledWithExactly(def.schemaDefinition)
          , 'schema not called with correct definition').to.be.true
          expect(res).to.deep.equal {a: 'mongoose schema stub'}
          done()

        it 'passes options to mongoose Schema constructor', (done) ->
          def.options = 'schema options'
          res = mongo.schemaFactory def
          expect(mongooseStub.Schema.calledOnce
          , 'schema not called exactly once').to.be.true
          expect(mongooseStub.Schema.calledWithNew()
          , 'schema not called with new').to.be.true
          expect(mongooseStub.Schema.calledWithExactly(
            def.schemaDefinition, def.options
          ), 'schema not called with correct options').to.be.true
          expect(res).to.deep.equal {a: 'mongoose schema stub'}
          done()

