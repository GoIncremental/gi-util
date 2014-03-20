tedious = require 'tedious'
crudModelFactory = require '../crudModelFactory'
queryQueue = require './queryQueue'
sqlHelper = require './sqlHelper'

class QueryBuilder
  constructor: (@table, @dbConnection, @idColumn) ->
    @query = ""
    @returnArray = true

  exec: (cb) ->
    queryQueue.runQuery @query, @returnArray, @dbConnection, cb
  
  create: (obj, cb) ->
    @returnArray = false
    values = "VALUES"
    @query = 'INSERT INTO ' + @table
    separator = ' ('
    for key, value of obj
      values += separator + "'" + value + "'"
      @query += separator + key
      separator = ', '

    @query += ') ' + values + ') '
    @exec cb

  find: (query, cb) ->
    @returnArray = true
    @query = "SELECT * FROM " + @table
    @query += sqlHelper.generateWhereClause(query)
    if cb?
      @exec cb
    else
      @

  findOne: (query, cb) ->
    @returnArray = false
    @query = 'SELECT TOP 1 * FROM ' + @table
    @query += sqlHelper.generateWhereClause query
    if cb?
      @exec cb
    else
      @

  sort: (query, cb) ->
    #TODO: add sort@query = @query + " ORDER BY "
    if cb?
      @exec cb
    else
      @

  skip: (num, cb) ->
    #TODO: add pagination sort@query = @query + " ORDER BY "
    if cb?
      @exec cb
    else
      @

  limit: (num, cb) ->
    #TODO: add Top num to query
    if cb?
      @exec cb
    else
      @

  count: (query, cb) ->
    @query = 'SELECT COUNT(*) FROM ' + @table
    if cb?
      @exec cb
    else
      @

  findByIdAndUpdate: (id, obj, cb) ->
    @returnArray = false
    value = ""
    @query = 'UPDATE ' + @table + ' SET'
    separator = ''
    for key, value of obj
      if key isnt @idColumn
        if value?
          @query += separator + " " + key + "= '" +
          value + "'"
          separator = ','
    @query += ' WHERE ' + @idColumn + ' = ' + id
    if cb
      @exec (err, obj) =>
        if err
          cb err, obj
        else
          query = {}
          query[@idColumn] = id
          @findOne query, cb
    else
      @

  remove: (query, cb) ->
    @returnArray = false

    @query = 'DELETE FROM ' + @table +
    ' WHERE ' + @idColumn + ' = ' + query[@idColumn]
    
    if cb?
      @exec cb
    else
      @

schemaFactory = (def) ->
  schema: def.schemaDefinition
  virtual: (name) ->
    get: (fn) ->
    set: (fn) ->
  methods: {}
  pre: (event, fn) ->

modelFactory = (def, dbConnection) ->
  collectionName = def.name
  if def.options?.collectionName?
    collectionName = def.options.collectionName

  idColumn = "_id"
  if def.options?.idColumn?
    idColumn = def.options.idColumn

  qb = new def.Qb(collectionName, dbConnection, idColumn)
  qb.modelName = def.name
  qb

module.exports =
  connect: (conf) ->
    dbConnection = new tedious.Connection(conf)
    dbConnection
  QueryBuilder: QueryBuilder
  schemaFactory: schemaFactory
  modelFactory: modelFactory
  crudFactory: crudModelFactory