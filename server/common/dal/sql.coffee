tedious = require 'tedious'
crudModelFactory = require '../crudModelFactory'
queryQueue = require './queryQueue'
sqlHelper = require './sqlHelper'

class QueryBuilder
  constructor: (@table, @dbConnection) ->
    @query = ""
    @returnArray = true

  exec: (cb) ->
    queryQueue.runQuery @query, @returnArray, @dbConnection, cb
  
  create: (obj, cb) ->
    @returnArray = true
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

  findByIdAndUpdate: (id, update, options, cb) ->
    @returnArray = false
    @query = 'SELECT TOP 1 * FROM ' + @table + ' WHERE _id = ' + id
    if cb?
      @exec cb
    else
      @

  remove: (query, cb) ->
    @returnArray = false
    @query = 'DELETE FROM ' + @table + ' WHERE _id = ' + query.id
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

  qb = new def.Qb(collectionName, dbConnection)
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