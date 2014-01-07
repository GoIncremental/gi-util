Q = require 'q'
tedious = require 'tedious'
queryQueue = []
queueInProgress = false

processQueryQueue = () ->
  nextQuery = queryQueue.shift()
  if nextQuery?
    queueInProgress = true
    result = []

    request = new tedious.Request nextQuery.query, (err, rowCount) ->
      if err
        nextQuery.promise.reject err
      else
        if nextQuery.returnArray
          nextQuery.promise.resolve result
        else
          nextQuery.promise.resolve result[0]
      #recursive call to process anything else on the queue
      processQueryQueue()

    request.on 'row', (columns) ->
      obj = {}
        
      columns.forEach (column) ->
        obj[column.metadata.colName] = column.value

      result.push obj
    nextQuery.conn.execSql request

  else
    queueInProgress = false
    return


runQuery = (query, returnArray, conn, cb) ->

  console.log 'running query ' + query
  #pop query on the queue
  deferred = Q.defer()

  obj =
    query: query
    returnArray: returnArray
    conn: conn
    promise: deferred

  queryQueue.push obj
  
  if !queueInProgress
    processQueryQueue()

  deferred.promise.nodeify cb

module.exports =
  runQuery: runQuery
  _processQueryQueue: processQueryQueue