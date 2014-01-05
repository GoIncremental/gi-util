expect = require('chai').expect
sinon = require 'sinon'
proxyquire = require 'proxyquire'
path = require 'path'
mongo = require './mongo'
sql = require './sql'
sqlHelper = require './sqlHelper'

module.exports = () ->
  describe 'dal', ->
    dal = null
    stubs =
      './mongo': 'mongoStub'
      './sql': 'sqlStub'

    beforeEach (done) ->
      dir = path.normalize __dirname + '../../../../../server'
      dal = proxyquire(dir + '/common/dal', stubs)
      done()

    describe 'Exports', ->

      it 'mongo', (done) ->
        expect(dal).to.have.ownProperty 'mongo'
        expect(dal.mongo).to.equal 'mongoStub'
        done()

      it 'sql', (done) ->
        expect(dal).to.have.ownProperty 'sql'
        expect(dal.sql).to.equal 'sqlStub'
        done()

      mongo()

      sql()

    describe 'Private', ->
      sqlHelper()
