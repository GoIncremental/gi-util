tedious = require 'tedious'
queryQueue = []
queueInProgress = false

processQueryQueue = () ->
  nextQuery = queryQueue.shift()
  if nextQuery?
    queueInProgress = true
    result = []
    console.log nextQuery.query
    request = new tedious.Request nextQuery.query, (err, rowCount) ->
      if err
        nextQuery.cb err
      else
        if nextQuery.returnArray
          nextQuery.cb null, result
        else
          if result[0]
            nextQuery.cb null, result[0]
          else
            nextQuery.cb null, {}
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

  obj =
    query: query
    returnArray: returnArray
    conn: conn
    cb: cb


  queryQueue.push obj

  if !queueInProgress
    processQueryQueue()

  return

module.exports =
  runQuery: runQuery
  _processQueryQueue: processQueryQueue