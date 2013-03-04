conf = require '../conf'
mongoose = require 'mongoose'
path = require 'path'
dir =  path.normalize __dirname + '../../../../server'

port = parseInt conf.db.port
mongoose.connect conf.db.host, conf.db.name, port

models = require dir + '/models'
models.loadSchemas mongoose

module.exports = models