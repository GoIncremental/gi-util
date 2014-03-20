path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect
proxyquire = require 'proxyquire'

dir =  path.normalize __dirname + '../../../../../server'

module.exports = () ->
  describe 'sql', ->
    sql = null
    
    tediousStub =
      Connection: ->
      Request: ->
    
    queryQueueStub =
      runQuery: ->

    sqlHelperStub =
      generateWhereClause: ->
        ""

    stubs =
      'tedious': tediousStub
      '../crudModelFactory': 'crudModelFactoryStub'
      './queryQueue': queryQueueStub
      './sqlHelper': sqlHelperStub

    beforeEach ->
      sql = proxyquire(dir + '/common/dal/sql', stubs)

    describe 'Exports', ->
      it 'connect', (done) ->
        expect(sql).to.have.ownProperty 'connect'
        expect(sql.connect).to.be.a 'function'
        done()

      it 'QueryBuilder', (done) ->
        expect(sql).to.have.ownProperty 'QueryBuilder'
        done()

      it 'schemaFactory', (done) ->
        expect(sql).to.have.ownProperty 'schemaFactory'
        done()

      it 'modelFactory', (done) ->
        expect(sql).to.have.ownProperty 'modelFactory'
        done()

      it 'crudFactory', (done) ->
        expect(sql).to.have.ownProperty 'crudFactory'
        done()

      describe 'QueryBuilder', ->
        qb = {}
        
        beforeEach ->
          qb = new sql.QueryBuilder("aTable", "aConnection", "_id")
        
        describe 'Properties', ->
          it 'query: String', (done) ->
            expect(qb).to.have.ownProperty 'query'
            expect(qb.query).to.be.a 'String'
            expect(qb.query).to.equal ""
            done()

          it 'returnArray: Boolean (true)', (done) ->
            expect(qb).to.have.ownProperty 'returnArray'
            expect(qb.returnArray).to.be.a 'boolean'
            expect(qb.returnArray).to.be.true
            done()

          it 'table: String', (done) ->
            expect(qb).to.have.ownProperty 'table'
            expect(qb.table).to.be.a 'String'
            expect(qb.table).to.equal 'aTable'
            done()

          it 'dbConnection: Object', (done) ->
            expect(qb).to.have.ownProperty 'dbConnection'
            expect(qb.dbConnection).to.equal 'aConnection'
            done()

        describe 'Methods', ->
          it 'exec: (callback) ->', (done) ->
            expect(qb).to.have.property 'exec'
            expect(qb.exec).to.be.a 'function'
            done()

          it 'create: (obj, callback) ->', (done) ->
            expect(qb).to.have.property 'create'
            expect(qb.create).to.be.a 'function'
            done()

          it 'find: (query, callback) ->', (done) ->
            expect(qb).to.have.property 'find'
            expect(qb.find).to.be.a 'function'
            done()

          it 'findOne: (query, callback) ->', (done) ->
            expect(qb).to.have.property 'findOne'
            expect(qb.findOne).to.be.a 'function'
            done()

          it 'sort: (query, callback) ->', (done) ->
            expect(qb).to.have.property 'sort'
            expect(qb.sort).to.be.a 'function'
            done()

          it 'skip: (num, cb) ->', (done) ->
            expect(qb).to.have.property 'skip'
            expect(qb.skip).to.be.a 'function'
            done()

          it 'limit: (num, cb) ->', (done) ->
            expect(qb).to.have.property 'limit'
            expect(qb.limit).to.be.a 'function'
            done()

          it 'count: (query, cb) ->', (done) ->
            expect(qb).to.have.property 'count'
            expect(qb.count).to.be.a 'function'
            done()

          it 'findByIdAndUpdate: (id, update, options, callback)', (done) ->
            expect(qb).to.have.property 'findByIdAndUpdate'
            expect(qb.findByIdAndUpdate).to.be.a 'function'
            done()

          it 'remove: (query, callback)', (done) ->
            expect(qb).to.have.property 'remove'
            expect(qb.remove).to.be.a 'function'
            done()

          describe 'exec', ->
            beforeEach ->
              sinon.spy queryQueueStub, 'runQuery'
            
            afterEach ->
              queryQueueStub.runQuery.restore()

            it 'calls runQuery with query returnArray dbConnection and cb'
            , (done) ->
              qb.query = 'hello'
              qb.returnArray = true
              qb.dbConnection = 'bob'
              qb.exec 'aCallback'
              expect(queryQueueStub.runQuery.calledWithExactly(
                'hello', true, 'bob', 'aCallback'
              ), 'runQuery not given correct arguments').to.be.true
              done()

          describe 'create', ->
            beforeEach ->
              sinon.spy qb, 'exec'

              query =
                'abc': 1
                'def': 'bob'
              qb.returnArray = false
              qb.create query, 'callbackstub'

            it 'sets returnArray to false', (done) ->
              expect(qb.returnArray).to.be.false
              done()

            it 'inserts into correct table', (done) ->
              expect(qb.query.indexOf('INSERT INTO aTable')).to.equal 0
              done()

            it 'decomposes the query object into sql', (done) ->
              expect(qb.query)
              .to.equal "INSERT INTO aTable (abc, def) VALUES ('1', 'bob') "
              done()

            it 'executes the query', (done) ->
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly('callbackstub')).to.be.true
              done()

          describe 'find', ->
            beforeEach ->
              sinon.spy qb, 'exec'
              sinon.stub sqlHelperStub, 'generateWhereClause'
              qb.returnArray = false

            afterEach ->
              sqlHelperStub.generateWhereClause.restore()

            it 'sets returnArray to true', (done) ->
              qb.find "abc", "123"
              expect(qb.returnArray).to.be.true
              done()

            it 'selects from correct table', (done) ->
              qb.find "abc", "another callback"
              expect(qb.query.indexOf('SELECT * FROM aTable')).to.equal 0
              done()

            it 'generates a whereclause from the query', (done) ->
              qb.find "abc", "another callback"
              expect(sqlHelperStub.generateWhereClause.calledWithExactly 'abc')
              .to.be.true
              done()

            it 'appends whereclase to the query', (done) ->
              sqlHelperStub.generateWhereClause.returns " WHERE CLAUSE"
              qb.find "abc", "another callback"
              expect(qb.query).to.equal "SELECT * FROM aTable WHERE CLAUSE"
              done()

            it 'returns the query builder if no callback', (done) ->
              res = qb.find "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.find "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.find "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.find "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'findOne', ->
            beforeEach ->
              sinon.spy qb, 'exec'
              sinon.stub sqlHelperStub, 'generateWhereClause'

            afterEach ->
              sqlHelperStub.generateWhereClause.restore()

            it 'selects from correct table', (done) ->
              qb.findOne "abc", "another callback"
              expect(qb.query.indexOf('SELECT TOP 1 * FROM aTable')).to.equal 0
              done()

            it 'generates a whereclause from the query', (done) ->
              qb.findOne "abc", "another callback"
              expect(sqlHelperStub.generateWhereClause.calledWithExactly 'abc')
              .to.be.true
              done()

            it 'appends whereclase to the query', (done) ->
              sqlHelperStub.generateWhereClause.returns " WHERE CLAUSE"
              qb.findOne "abc", "another callback"
              expect(qb.query)
              .to.equal "SELECT TOP 1 * FROM aTable WHERE CLAUSE"
              done()

            it 'returns the query builder if no callback', (done) ->
              res = qb.findOne "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.findOne "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.findOne "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.findOne "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'sort', ->
            beforeEach ->
              sinon.spy qb, 'exec'
            
            it 'returns the query builder if no callback', (done) ->
              res = qb.sort "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.sort "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.sort "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.sort "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'skip', ->
            beforeEach ->
              sinon.spy qb, 'exec'
            
            it 'returns the query builder if no callback', (done) ->
              res = qb.skip "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.skip "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.skip "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.skip "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'limit', ->
            beforeEach ->
              sinon.spy qb, 'exec'
            
            it 'returns the query builder if no callback', (done) ->
              res = qb.limit "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.limit "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.limit "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.limit "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'count', ->
            beforeEach ->
              sinon.spy qb, 'exec'
            
            it 'sets the query to count all rows in the table', (done) ->
              qb.count "abc", "def"
              expect(qb.query).to.equal 'SELECT COUNT(*) FROM aTable'
              done()

            it 'returns the query builder if no callback', (done) ->
              res = qb.count "abc"
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.count "abc"
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.count "abc", "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.count "abc", "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

          describe 'findByIdAndUpdate', ->
            beforeEach ->
              sinon.spy qb, 'exec'
            
            it 'sets the query', (done) ->
              qb.findByIdAndUpdate "123", {abc: "def"}, "callback"
              expect(qb.query)
              .to.equal "UPDATE aTable SET abc= 'def' WHERE _id = 123"
              done()

            it 'returns the query builder if no callback', (done) ->
              res = qb.findByIdAndUpdate "123", {abc: "def"}
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.findByIdAndUpdate "123", {abc: "def"}
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.findByIdAndUpdate "123", {abc: "def"}, "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.count qb.findByIdAndUpdate "123", {abc: "def"}, "callback"
              expect(qb.exec.calledOnce).to.be.true
              done()

          describe 'remove', ->
            beforeEach ->
              sinon.spy qb, 'exec'
              qb.returnArray = true

            it 'sets returnArray to false', (done) ->
              qb.remove {id: "123"}, "callback"
              expect(qb.returnArray).to.be.false
              done()

            it 'removes based on the id given in query', (done) ->
              qb.remove {_id: "123"}, "callback"
              expect(qb.query)
              .to.equal 'DELETE FROM aTable WHERE _id = ' + "123"
              done()

            it 'returns the query builder if no callback', (done) ->
              res = qb.remove {id: "123"}
              expect(qb).to.equal res
              done()

            it 'does not run a query if no callback passed', (done) ->
              qb.remove {id: "123"}
              expect(qb.exec.notCalled, "exec was called").to.be.true
              done()

            it 'returns nothing if callback is specified', (done) ->
              res = qb.remove {id: "123"}, "callback"
              expect(res).to.not.exist
              done()

            it 'executes the query if callback is specified', (done) ->
              qb.remove {id: "123"}, "callback"
              expect(qb.exec.calledOnce).to.be.true
              expect(qb.exec.calledWithExactly "callback").to.be.true
              done()

      describe 'connect', ->
        beforeEach ->
          sinon.stub tediousStub, 'Connection'
          tediousStub.Connection.returns {a: 'sql connection'}

        afterEach ->
          tediousStub.Connection.restore()

        it 'creates a new sql connection with conf', (done) ->
          res = sql.connect 'bob'
          expect(tediousStub.Connection.calledOnce).to.be.true
          expect(tediousStub.Connection.calledWithExactly 'bob')
          .to.be.true
          expect(res).to.deep.equal {a: 'sql connection'}
          done()

      describe 'schemaFactory', ->
        result = {}
        def =
          schemaDefiniton: 'a definition'
        beforeEach ->
          result = sql.schemaFactory def

        it 'sets schema to the given defition', (done) ->
          expect(result).to.have.ownProperty 'schema'
          expect(result.schema).to.equal def.schemaDefinition
          done()

        it 'defines a virtual method on the returned schema object'
        , (done) ->
          expect(result).to.have.ownProperty 'virtual'
          expect(result.virtual).to.be.a 'function'
          done()

        it 'the virtual method defines a get function', (done) ->
          virtualResult = result.virtual 'bob'
          expect(virtualResult).to.have.ownProperty 'get'
          expect(virtualResult.get).to.be.a 'function'
          expect(virtualResult.get('abc')).to.not.exist
          done()

        it 'the virtual method defines a set function', (done) ->
          virtualResult = result.virtual 'bob'
          expect(virtualResult).to.have.ownProperty 'set'
          expect(virtualResult.set).to.be.a 'function'
          expect(virtualResult.set('abc')).to.not.exist
          done()

        it 'defines an empty methods object on the returned schema object'
        , (done) ->
          expect(result).to.have.ownProperty 'methods'
          expect(result.methods).to.be.an 'object'
          expect(result.methods).to.deep.equal {}
          done()

        it 'defines a pre function on the returned schema object', (done) ->
          expect(result).to.have.ownProperty 'pre'
          expect(result.pre).to.be.a 'function'
          expect(result.pre('abc','def')).to.not.exist
          done()

      describe 'modelFactory', ->
        def = {}
        res = null
        beforeEach ->
          def =
            name: 'a new model'
            Qb: sinon.spy()
        
        afterEach ->
          def = null

        it 'returns a new query builder instance from def.qb', (done) ->
          res = sql.modelFactory def, 'asqlcon'
          expect(def.Qb.calledWithNew()).to.be.true
          done()
        
        it 'uses def.name for the table name', (done) ->
          res = sql.modelFactory def, 'asqlcon'
          expect(def.Qb.calledWith('a new model')).to.be.true
          done()

        it 'uses def.options.collectionName for the table name if present'
        , (done) ->
          def.options =
            collectionName: 'anothername'
          res = sql.modelFactory def, 'asqlcon'
          expect(def.Qb.calledOnce).to.be.true
          expect(def.Qb.calledWith('anothername')).to.be.true
          done()
        
        it 'uses the given database connection for the connection', (done) ->
          res = sql.modelFactory def, 'asqlcon'
          expect(def.Qb.calledWith('a new model', 'asqlcon')).to.be.true
          done()

        it 'sets modelName on the QueryBuilder object to the def.name'
        , (done) ->
          res = sql.modelFactory def, 'asqlcon'
          expect(res).to.have.property 'modelName'
          expect(res.modelName).to.equal 'a new model'
          def.options =
            collectionName: 'a third name'
          res2 = sql.modelFactory def, 'asqlcon'
          expect(res2.modelName).to.equal 'a new model'
          done()


      describe 'crudFactory', ->
        it 'returns the common.crudModelFactory', (done) ->
          expect(sql.crudFactory).to.equal 'crudModelFactoryStub'
          done()
