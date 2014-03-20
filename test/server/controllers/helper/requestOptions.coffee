path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
moment = require 'moment'
dir =  path.normalize __dirname + '../../../../../server'
proxyquire = require 'proxyquire'


module.exports = () ->
  
  stubs =
    './querySplitter':
      processSplits: sinon.stub().returns [ {a: '1'}, {a: '2'} ]
      processSplit: sinon.stub().returnsArg 0

  requestOptions = proxyquire dir + '/controllers/helper/requestOptions', stubs

  describe 'Exports', (done) ->
    
    it 'getOptions: Function', (done) ->
      expect(requestOptions).to.have.ownProperty 'getOptions'
      expect(requestOptions.getOptions).to.be.a 'function'
      done()

    describe 'getOptions: Function(req) -> {options}', ->
      getOptions = requestOptions.getOptions
      req = null
      model = null
      options = null
      
      beforeEach (done) ->
        req =
          systemId: '123'
          giFilter:
            aModel: 'anId'
            aParent: 'aParentId'

        model =
          name: 'aModel'

        done()
      
      afterEach (done) ->
        stubs['./querySplitter'].processSplits.reset()
        done()

      it 'sets query.systemId to req.systemId', (done) ->
        options = getOptions req, model
        expect(options.query.systemId).to.equal req.systemId
        done()

      it 'if gi filter is specified for the model name ' +
      'set options.query._id', (done) ->
        options = getOptions req, model
        expect(options.query._id).to.equal req.giFilter.aModel
        done()

      it 'but not if gi filter is specified for a different model', (done) ->
        model.name = 'anotherModel'
        options = getOptions req, model
        expect(options.query._id).to.not.exist
        done()

      it 'sets options.query[parent.field] for any parents specified' +
      ' in model.releations().parents', (done) ->
        
        model.relations = () ->
          parents: [
            {modelName: 'aParent', field: 'parentModelId'}
            {modelName: 'anotherParent', field: 'anotherParentModelId'}
          ]

        options = getOptions req, model
        expect(options.query.parentModelId).to.equal 'aParentId'
        expect(options.query.anotherParentModelId).to.not.exist
        
        done()

      it 'does not set options.max if req.query.max does not exist', (done) ->
        options = getOptions req, model
        expect(options.max).to.not.exist
        done()

      it 'sets options.max for req.query.max', (done) ->
        req.query =
          max: 10
        options = getOptions req, model
        expect(options.max).to.equal req.query.max
        done()

      it 'does not set options.max if the value is not a number', (done) ->
        req.query =
          max: 'bob'
        options = getOptions req, model
        expect(options.max).to.not.exist
        done()

      it 'sets options.max to 0 if the value is less than 1', (done) ->
        req.query =
          max: -5
        options = getOptions req, model
        expect(options.max).to.equal 0
        done()

      it 'does not set options.sort if req.query.sort not given', (done) ->
        options = getOptions req, model
        expect(options.sort).to.not.exist
        done()

      it 'sets options.sort to req.query.sort', (done) ->
        req.query =
          sort: 'bob'
        options = getOptions req, model
        expect(options.sort).to.equal req.query.sort
        done()
      
      it 'does not set options.page if req.query.page not given', (done) ->
        options = getOptions req, model
        expect(options.page).to.not.exist
        done()

      it 'sets options.page to req.query.page', (done) ->
        req.query =
          page: 'alice'
        options = getOptions req, model
        expect(options.page).to.equal req.query.page
        done()


      it 'populates query.$or if query contains *or*', (done) ->
        req.query =
          a: '1*or*2'
        options = getOptions req, model

        expect(options.query).to.have.property '$or'
        expect(options.query.$or).to.deep.equal [{a: '1'}, {a: '2'}]
        done()

      it 'calls processSplits with array of splits if query contains *or*'
      , (done) ->
        req.query =
          a: 'jack*or*jill'
              
        options = getOptions req, model
        expect(stubs['./querySplitter'].processSplits.called).to.be.true
        expect(stubs['./querySplitter'].processSplits
        .calledWith(['jack', 'jill'], 'a')).to.be.true
        done()

      it 'populates query.$and if query contains *and*', (done) ->
        req.query =
          a: '1*and*2'
        
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and).to.deep.equal [{a: '1'}, {a: '2'}]
        done()
      
      it 'calls processSplits with array of splits if query contains *and*'
      , (done) ->
        req.query =
          b: 'alice*and*bob'

        options = getOptions req, model
        expect(stubs['./querySplitter'].processSplits.called).to.be.true
        expect(stubs['./querySplitter'].processSplits
        .calledWith(['alice', 'bob'], 'b')).to.be.true
        done()


      it 'calls processSplit if query does contains neither *and* nor *or*'
      , (done) ->
        req.query =
          c: 'charlie'

        options = getOptions req, model
        expect(stubs['./querySplitter'].processSplits.called).to.be.false
        expect(stubs['./querySplitter'].processSplit.called).to.be.true
        expect(stubs['./querySplitter'].processSplit
        .calledWith('charlie', 'c')).to.be.true
        done()
