mongoose = require 'mongoose'

module.exports = (conf) ->
  port = parseInt conf.port

  opts =
    user: conf.username
    pass: conf.password

  mongoose.connect conf.host, conf.name, port, opts