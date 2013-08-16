path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
moment = require 'moment'
dir =  path.normalize __dirname + '../../../../server'

module.exports = () ->
  
  helper = require dir + '/controllers/helper'
  describe 'Exports', (done) ->
    
    it 'getOptions: Function', (done) ->
      expect(helper).to.have.ownProperty 'getOptions'
      expect(helper.getOptions).to.be.a 'function'
      done()

    describe 'getOptions: Function(req) -> {options}', ->
      getOptions = helper.getOptions
      req = null
      model = null
      options = null

      beforeEach (done) ->
        req =
          systemId: '123'
          gintFilter:
            aModel: 'anId'
            aParent: 'aParentId'

        model =
          name: 'aModel'

        done()

      it 'sets query.systemId to req.systemId', (done) ->
        options = getOptions req, model
        expect(options.query.systemId).to.equal req.systemId
        done()

      it 'if gint filter is specified for the model name ' +
      'set options.query._id', (done) ->
        options = getOptions req, model
        expect(options.query._id).to.equal req.gintFilter.aModel
        done()

      it 'but not if gint filter is specified for a different model', (done) ->
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

      it 'sets options.query to anything else given in req.query', (done) ->
        req.query =
          a: 'alice'
          b: 'bob'
        options = getOptions req, model
        expect(options.query).to.have.property 'a', 'alice'
        expect(options.query).to.have.property 'b', 'bob'
        done()

      it 'looks for *and* delimiter', (done) ->
        req.query =
          a: '*and*'
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and).to.be.an 'array'
        done()

      it 'populates a multi term *and* delimited query', (done) ->
        req.query =
          a: 'jack*and*jill'
        options = getOptions req, model

        expect(options.query).to.have.property '$and'
        expect(options.query.$and).to.be.an 'array'
        expect(options.query.$and).to.deep.equal [{a: 'jack'}, {a: 'jill'}]
        done()

      it 'handles less than queries', (done) ->
        req.query =
          a: 'jack*and*lt|5'
        
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$lt', '5'
        done()
      
      it 'handles less than or equal queries', (done) ->
        req.query =
          a: 'jack*and*lte|6'
        
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$lte', '6'
        done()

      it 'handles greater than queries', (done) ->
        req.query =
          a: 'jack*and*gt|7'
        
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$gt', '7'
        done()

      it 'handles greater than or equal queries', (done) ->
        req.query =
          a: 'jack*and*gte|8'
        
        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$gte', '8'
        done()

      it 'handles less than date queries with YYYY-MM-DD format'
      , (done) ->
        req.query =
          a: 'jack*and*ltdate|2013-08-09'

        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$lt'
        expect(moment(options.query.$and[1].a.$lt)
        .isSame('2013-08-09')).to.be.true
        done()

      it 'handles less than date queries with YYYY-MM-DDTHH:mm:ss format'
      , (done) ->
        req.query =
          a: 'jack*and*ltdate|2013-08-09T00:00:00'

        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$lt'
        expect(moment(options.query.$and[1].a.$lt)
        .isSame('2013-08-09')).to.be.true
        done()
      
      it 'handles greater than date queries with YYYY-MM-DD format'
      , (done) ->
        req.query =
          a: 'jack*and*gtdate|2013-08-09'

        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$gt'
        expect(moment(options.query.$and[1].a.$gt)
        .isSame('2013-08-09')).to.be.true
        done()

      it 'handles treater than date queries with YYYY-MM-DDTHH:mm:ss format'
      , (done) ->
        req.query =
          a: 'jack*and*gtdate|2013-08-09T00:00:00'

        options = getOptions req, model
        expect(options.query).to.have.property '$and'
        expect(options.query.$and[1].a).to.exist
        expect(options.query.$and[1].a).to.have.property '$gt'
        expect(moment(options.query.$and[1].a.$gt)
        .isSame('2013-08-09')).to.be.true
        done()