path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect

dir =  path.normalize __dirname + '../../../../../server'

module.exports = () ->
  describe 'sqlHelper', ->
    helper = null

    beforeEach ->
      helper = require(dir + '/common/dal/sqlHelper',)

    describe 'Exports', ->
      it 'generateWhereClause', (done) ->
        expect(helper).to.have.ownProperty 'generateWhereClause'
        expect(helper.generateWhereClause).to.be.a 'function'
        done()

      describe 'generateWhereClause (query)', ->

        it 'decomposes query object into SQL Where Clause', (done) ->
          query =
            "a": "b"

          result = helper.generateWhereClause query
          expect(result).to.equal " WHERE a = 'b'"
          query["123"] = 456
          result = helper.generateWhereClause query
          expect(result).to.equal " WHERE 123 = '456' AND a = 'b'"
          done()

        it 'puts a leading space into result', (done) ->
          query =
            "a": "b"
            "123": 456
          result = helper.generateWhereClause query
          expect(result.indexOf(" ")).to.equal 0
          done()

        it 'returns an empty string if no query', (done) ->
          result = helper.generateWhereClause()
          expect(result).to.equal ""
          result = helper.generateWhereClause({})
          expect(result).to.equal ""
          result = helper.generateWhereClause(null)
          expect(result).to.equal ""
          done()