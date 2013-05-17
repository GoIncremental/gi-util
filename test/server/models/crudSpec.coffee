should = require 'should'
mongoose = require 'mongoose'
models = require './models'
sinon = require 'sinon'
assert = require 'assert'

describe 'Crud Model', ->
  
  resource =
    find: -> this
    name: 'bobby'
    findByIdAndUpdate: ->
    findOne: -> this
    sort: -> this
    skip: -> this
    limit: -> this
    exec: ->
    count: ->

  options =
    query:
      bob: 'jack'
  
  it 'Has a name', (done) ->
    crud = models.crud resource
    crud.name.should.equal resource.name
    done()

  it 'passes on the query to find', (done) ->
    find = sinon.spy resource, 'find'

    callback = sinon.spy()
    crud = models.crud resource
    
    crud.find options, callback

    assert find.calledWith(options.query)

    find.restore()
    done()

  it 'calls sort after find', (done) ->
    find = sinon.spy resource, 'find'
    sort = sinon.spy resource, 'sort'

    callback = sinon.spy()
    crud = models.crud resource

    crud.find options, callback

    assert sort.calledAfter(find), "sort called before find"
    
    find.restore()
    sort.restore()

    done()

  it 'default to no sort', (done) ->
    find = sinon.spy resource, 'find'
    sort = sinon.spy resource, 'sort'

    crud = models.crud resource

    crud.find options

    assert sort.calledWith({}), "sort did not default to {}"
   
    find.restore()
    sort.restore()
    done()

  it 'calls sort with option value', (done) ->
    find = sinon.spy resource, 'find'
    sort = sinon.spy resource, 'sort'

    callback = sinon.spy()
    crud = models.crud resource

    options.sort = {bob: "desc"}
    crud.find options, callback
    assert sort.calledWith(options.sort), "sort called incorrectly"
    
    find.restore()
    sort.restore()
    done()
  
  it 'defaults to page 1 max 10000', (done) ->
    skip = sinon.spy resource, 'skip'
    limit = sinon.spy resource, 'limit'

    callback = sinon.spy()
    crud = models.crud resource

    crud.find options, callback
    assert skip.calledWith(0)
    assert limit.calledWith(10000)

    skip.restore()
    limit.restore()
    done()

  it 'can paginate', (done) ->
    sort = sinon.spy resource, 'sort'
    skip = sinon.spy resource, 'skip'
    limit = sinon.spy resource, 'limit'

    callback = sinon.spy()
    crud = models.crud resource

    options.page = 3
    options.max = 10

    crud.find options, callback

    assert skip.calledAfter(sort), "skip called out of sequence"
    assert limit.calledAfter(skip), "limit called out of sequence"
    assert skip.calledWith(20), "skip set incorrectly"
    assert limit.calledWith(10), "per page limit set incorrectly"
    
    sort.restore()
    skip.restore()
    limit.restore()
    done()

  it 'returns an error if the find query fails', (done) ->
    exec = sinon.stub resource, 'exec'
    exec.callsArgWith 0, 'error', null

    callback = sinon.spy()
    
    crud = models.crud resource

    crud.find options, callback
    assert exec.called, "exec not called"
    assert callback.calledWith('error',null,0), "did not return correct error"

    exec.restore()
    done()

  it 'reports error if it cannot count the results', (done) ->
    exec = sinon.stub resource, 'exec'
    exec.callsArgWith 0, null, {}
    
    count = sinon.stub resource, 'count'
    count.callsArgWith 1, 'some error', 2

    callback = sinon.spy()
    
    crud = models.crud resource

    crud.find options, callback
    assert exec.called, "exec not called"
    assert count.called, "did not call count"
   
    assert callback.calledWith('could not count the results')
    , 'did not return count error message'

    exec.restore()
    count.restore()
    done()

  it 'counts the total number of results in a find', (done) ->
    exec = sinon.stub resource, 'exec'
    exec.callsArgWith 0, null, {}
    
    count = sinon.stub resource, 'count'
    count.callsArgWith 1, null, 25

    callback = sinon.spy()
    
    crud = models.crud resource

    options.max = 10
    crud.find options, callback
    assert callback.calledWith(null, {}, 3), 'did not return correct page count'

    callback.reset()

    options.max = 20
    crud.find options, callback
    assert callback.calledWith(null, {}, 2)
    , 'did not return correct page count 2'

    exec.restore()
    count.restore()
    done()

  it 'returns nothing if that is all you ask for', (done) ->
    exec = sinon.spy resource, 'exec'
    find = sinon.spy resource, 'find'
    callback = sinon.spy()
    
    crud = models.crud resource

    options.max = -3
    crud.find options, callback
    
    assert callback.calledWith(null,[]), "find failed on max = -3"

    callback.reset()

    options.max = 0
    crud.find options, callback

    assert callback.calledWith(null,[]), "find failed on max = 0"

    assert exec.callCount is 0, "exec should not have been called"
    assert find.callCount is 0, "find should not have been called"

    exec.restore()
    find.restore()
    done()

  it 'can update', (done) ->
    stub = sinon.stub resource, 'findByIdAndUpdate'
    stub.callsArgWith(2,null,{})
    spy = sinon.spy()
    crud = models.crud resource
    crud.update('123',{some: 'bad json'}, spy)
    assert spy.calledWith(null,{})
    stub.restore()
    done()

  it 'bubbles update errors', (done) ->
    stub = sinon.stub resource, 'findByIdAndUpdate'
    stub.callsArgWith(2,'error',{})
    spy = sinon.spy()
    crud = models.crud resource
    crud.update('123',{some: 'bad json'}, spy)
    assert spy.calledWith('error')
    done()

  it 'aliases findOneBy with findById', (done) ->
    stub = sinon.stub resource, 'findOne'
    stub.callsArgWith(1,null,{})

    spy = sinon.spy()
    crud = models.crud resource
    crud.findById '123', spy

    assert stub.calledWith({'_id': '123'}), "findOne not called correctly"
    assert spy.called, "callback spy not called"
    
    stub.restore()

    done()

  it 'returns errors from findOneBy', (done) ->
    stub = sinon.stub resource, 'findOne'
    stub.callsArgWith(1,"some error",{})

    spy = sinon.spy()

    crud = models.crud resource
    crud.findOneBy 'bob', '123', spy

    assert spy.calledWithExactly('some error')
    , "callback spy not called correctly"
    
    stub.restore()
    done()

  it 'returns error if nothing found', (done) ->
    stub = sinon.stub resource, 'findOne'
    stub.callsArgWith(1,null)

    spy = sinon.spy()

    crud = models.crud resource
    crud.findOneBy 'bob', '123', spy

    assert spy.calledWithExactly('Cannot find ' +
    resource.modelName + ' with bob: 123'), "callback spy not called correctly"
    
    stub.restore()
    done()

  it 'returns object if found', (done) ->
    stub = sinon.stub resource, 'findOne'
    stub.callsArgWith(1,null,{bob:"123"})

    spy = sinon.spy()

    crud = models.crud resource
    crud.findOneBy 'bob', '123', spy

    assert stub.calledWith({'bob': '123'}), "findOne not called correctly"
    assert spy.calledWithExactly(null, {bob: '123'})
    , "callback spy not called correctly"
    
    stub.restore()
    done()



