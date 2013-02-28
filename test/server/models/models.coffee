conf = require '../conf'
mongoose = require 'mongoose'
path = require 'path'
dir =  path.normalize __dirname + '../../../../server'

port = parseInt conf.db.port
mongoose.connect conf.db.host, conf.db.name, port

module.exports = require(dir + '/models')(mongoose)