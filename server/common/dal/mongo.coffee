_ = require 'underscore'
mongoose = require 'mongoose'
require('mongoose-long')(mongoose)
crudModelFactory = require '../crudModelFactory'
connectMongo = require 'connect-mongo'

getConnectionString = (conf) ->
  uri = "mongodb://"

  if conf.username?
    uri += conf.username + ":" + conf.password + "@"

  separator = ""
  if conf.servers?
    _.each conf.servers, (server) ->
      uri += separator +  server.host + ":" + server.port
      separator = ","
  else
    uri += conf.host + ":" + conf.port

  uri += "/" + conf.name
  if conf.ssl
    uri += "?ssl=true"
  else
    uri += "?ssl=false"
  if conf.authSource?
    uri += "&authSource=" + conf.authSource
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

    uri = getConnectionString(conf)

    mongoose.connect uri, {}

    mongoose.connection.on 'connected',  () ->
      cb() if cb

    mongoose.connection.on 'error', (err) ->
      cb(err) if cb

  sessionStore: (express, conf, cb) ->
    options =
      url: getConnectionString(conf)
    MongoStore = connectMongo(express)

    sessionStore = new MongoStore(options)
    sessionStore

  crudFactory: crudModelFactory
  modelFactory: modelFactory
  schemaFactory: schemaFactory
