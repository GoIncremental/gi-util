path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
moment = require 'moment'
dir =  path.normalize __dirname + '../../../../../server'

module.exports = () ->
  
  describe 'querySplitter', ->
    querySplitter = require dir + '/controllers/helper/querySplitter'

    describe 'Exports', (done) ->
      
      it 'processSplit: Function', (done) ->
        expect(querySplitter).to.have.ownProperty 'processSplit'
        expect(querySplitter.processSplit).to.be.a 'function'
        done()

      it 'processSplits: Function', (done) ->
        expect(querySplitter).to.have.ownProperty 'processSplits'
        expect(querySplitter.processSplits).to.be.a 'function'
        done()

      describe 'processSplits: Function([string], string) -> [string]', ->
        before (done) ->
          sinon.spy querySplitter, 'processSplit'
          done()
        
        afterEach (done) ->
          querySplitter.processSplit.reset()
          done()

        it 'calls processSplit on each split', (done) ->
          querySplitter.processSplits ['a', 'b'], 'c'

          expect(querySplitter.processSplit.calledTwice).to.be.true

          done()

        it 'returns an array an object for each split, each with key k'
        , (done) ->
          result = querySplitter.processSplits ['a', 'b'], 'c'
          expect(result).to.deep.equal [{c: 'a'}, {c: 'b'}]
          done()

      describe 'processSplit: Function(string) -> {} or string', (done) ->
        it 'returns the given argument if the argument does not contain |'
        , (done) ->
          result = querySplitter.processSplit 'hello there'
          expect(result).to.equal 'hello there'
          done()

        it 'creates less than objects', (done) ->
          result = querySplitter.processSplit 'lt|5'
          expect(result).to.have.property '$lt'
          expect(result.$lt).to.equal "5"
          done()

        it 'creates less than or equal objects', (done) ->
          result = querySplitter.processSplit 'lte|6'
          expect(result).to.have.property '$lte'
          expect(result.$lte).to.equal "6"
          done()

        it 'creates greater than objects', (done) ->
          result = querySplitter.processSplit 'gt|7'
          expect(result).to.have.property '$gt'
          expect(result.$gt).to.equal "7"
          done()

        it 'creates greater than or equal objects', (done) ->
          result = querySplitter.processSplit 'gte|8'
          expect(result).to.have.property '$gte'
          expect(result.$gte).to.equal "8"
          done()

        it 'recognises less than date queries with YYYY-MM-DD format'
        , (done) ->
          result = querySplitter.processSplit 'ltdate|2013-08-09'
          expect(result).to.have.property '$lt'
          expect(moment(result.$lt).isSame('2013-08-09')).to.be.true
          done()

        it 'recognises less than date queries with YYYY-MM-DDTHH:mm:ss format'
        , (done) ->
          result = querySplitter.processSplit 'ltdate|2013-08-09T00:00:00'
          expect(result).to.have.property '$lt'
          expect(moment(result.$lt).isSame('2013-08-09')).to.be.true
          done()

        it 'recognises greater than date queries with YYYY-MM-DD format'
        , (done) ->
          result = querySplitter.processSplit 'gtdate|2013-08-09'
          expect(result).to.have.property '$gt'
          expect(moment(result.$gt).isSame('2013-08-09')).to.be.true
          done()

        it 'recognises greater than date queries with' +
        ' YYYY-MM-DDTHH:mm:ss format'
        , (done) ->
          result = querySplitter.processSplit 'gtdate|2013-08-09T00:00:00'
          expect(result).to.have.property '$gt'
          expect(moment(result.$gt).isSame('2013-08-09')).to.be.true
          done()