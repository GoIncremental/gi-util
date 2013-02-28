conf = require '../conf'
mongoose = require 'mongoose'
path = require 'path'
dir =  path.normalize __dirname + '../../../../server'

port = parseInt conf.db.port
mongoose.connect conf.db.host, conf.db.name, port

models = require dir + '/models'
models.loadSchemas mongoose

#create a fake mongo module for testing the counter
Schema = mongoose.Schema
dummySchema = new Schema {name: 'String', number: 'Number' }
mongoose.model 'dummy', dummySchema

module.exports = models