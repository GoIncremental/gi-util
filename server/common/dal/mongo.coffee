_ = require 'underscore'
mongoose = require 'mongoose'
require('mongoose-long')(mongoose)
crudModelFactory = require '../crudModelFactory'
connectMongo = require 'connect-mongostore'

getConnectionString = (conf) ->
  uri = "mongodb://"
  separator = ""
  if conf.servers?
    _.each conf.servers, (server) ->
      uri += separator +  server.host + ":" + server.port + "/" + conf.name
      separator = ","

  else
    uri += conf.host + ":" + conf.port + "/" + conf.name
  uri

schemaFactory = (def) ->
  if def.options?
    _schema = new mongoose.Schema def.schemaDefinition, def.options
  else
    _schema = new mongoose.Schema def.schemaDefinition
  _schema

modelFactory = (def) ->
  if def.options?.collectionName?
    mongoose.model def.name, def.schema, def.options.collectionName
  else
    mongoose.model def.name, def.schema

module.exports =

  connect: (conf, cb) ->
    port = parseInt conf.port

    opts =
      user: conf.username
      pass: conf.password
    uri = getConnectionString(conf)
    mongoose.connect uri, opts
    
    mongoose.connection.on 'connected',  () ->
      cb() if cb

  sessionStore: (express, conf) ->
    MongoStore = connectMongo(express)

    if conf.servers?
      db =
        name: conf.name
        servers: conf.servers
    else
      db = 
        name: conf.name
        servers: [{ host: conf.host, port: conf.port}]

    sessionStore = new MongoStore({db: db})    
    sessionStore

  crudFactory: crudModelFactory
  modelFactory: modelFactory
  schemaFactory: schemaFactory