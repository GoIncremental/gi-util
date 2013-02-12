should = require 'should'
path = require 'path'

dir =  path.normalize __dirname + '../../../../server'

describe 'Crud Controller', ->
  crud = require dir + '/controllers/crud'
  mockModel = require '../mocks/crud'
  crudController = crud mockModel
  describe 'Create', ->
    it 'returns model as json with OK Status', (done) ->
      req =
        body:
          id: 'toto'
      res =
        json: (code, result) ->
          code.should.equal 200
          result.should.equal req.body
          done()
      crudController.create(req,res)

    it 'returns no data and 500 Status', (done) ->
      req =
        body: null
      res =
        json: (code, result) ->
          code.should.equal 500
          should.not.exist result
          done()
      crudController.create(req,res)
  describe 'Update', ->
    it 'returns model as json with OK Status', (done) ->
      req =
        params:
          id: 'toto'
        body: {}
      res =
        json: (code, result) ->
          code.should.equal 200
          result.should.equal req.body
          done()
      crudController.update(req,res)

    it 'returns invalid request if params id is not defined', (done) ->
      req =
        params: {}
        body: {}
      res =
        json: (code, result) ->
          code.should.equal 400
          should.not.exist result
          done()
      crudController.update(req,res)

    it 'returns doesnt exists result 400 if id doesnt exists in db', (done) ->
      req =
        params:
          id: 'InvalidId'
        body: {}
      res =
        json: (code, result) ->
          code.should.equal 400
          should.not.exist result
          done()
      crudController.update(req,res)
    it 'returns invalid request if _id exists on body', (done) ->
      req =
        params:
          id: 'ValidId'
        body:
          _id: 'ValidId'
      res =
        json: (code, result) ->
          code.should.equal 400
          result.should.have.property 'error'
          , 'Do not specify an _id on update request'
          done()
      crudController.update(req,res)
  describe 'Destroy', ->
    it 'returns model as json with OK Status', (done) ->
      req =
        params:
          id: 'validId'
      res =
        json: (code, result) ->
          should.exist code
          code.should.equal 200
          should.not.exist result
          done()
      crudController.destroy(req,res)

    it 'returns 404 Status if no params', (done) ->
      req =
        params: null
      res =
        json: (code, result) ->
          code.should.equal 404
          should.not.exist result
          done()
      crudController.destroy(req,res)
    it 'returns 404 Status if id doesnt exists', (done) ->
      req =
        params:
          id: null
      res =
        json: (code, result) ->
          code.should.equal 404
          should.not.exist result
          done()
      crudController.destroy(req,res)
  describe 'Show', ->
    it 'returns single object as json with OK Status', (done) ->
      req =
        params:
          id: 'validId'
      res =
        json: (code, result) ->
          should.exist code
          code.should.equal 200
          result._id.should.equal req.params.id
          done()
      crudController.show(req,res)

    it 'returns 404 Status if no params', (done) ->
      req =
        params: null
      res =
        json: (code, result) ->
          code.should.equal 404
          should.not.exist result
          done()
      crudController.show(req,res)
    it 'returns 404 Status if id doesnt exists', (done) ->
      req =
        params:
          id: null
      res =
        json: (code, result) ->
          code.should.equal 404
          should.not.exist result
          done()
      crudController.show(req,res)
    it 'returns 404 Status if valid id is not found', (done) ->
      req =
        params:
          id: '111111111111111111111111'
      res =
        json: (code, results) ->
          should.exist code
          code.should.equal 404
          should.not.exist results
          done()
      crudController.show(req,res)
    it 'returns 404 Status if id is invalid', (done) ->
      req =
        params:
          id: 'invalidId'
      res =
        json: (code, results) ->
          should.exist code
          code.should.equal 404
          should.not.exist results
          done()
      crudController.show(req,res)
  describe 'Index', ->
    it 'returns an array of object as json with OK Status', (done) ->
      i = 0
      testCounter = ->
        i = i + 1
        if i is 1
          done()
      createRes = (qty) ->
        json: (code, result) ->
          should.exist code
          code.should.equal 200
          if qty < 0
            qty = 0
          result.length.should.equal qty
          testCounter()
      createReq = (qty) ->
        query:
          max: qty

      qty = 4
      crudController.index(createReq(qty),createRes(qty))
      qty = 12
      crudController.index(createReq(qty),createRes(qty))
      qty = -7
      crudController.index(createReq(qty),createRes(qty))

    it 'returns an array of object as json with OK Status if no max', (done) ->
      req =
        query: {}
      res =
        json: (code, result) ->
          should.exist code
          code.should.equal 200
          result.length.should.equal 10
          done()
      crudController.index(req,res)

    it 'returns an array of object as json with OK Status if no max', (done) ->
      req =
        query:
          max: 666
      res =
        json: (code, result) ->
          should.exist code
          code.should.equal 404
          should.not.exist result
          done()
      crudController.index(req,res)
