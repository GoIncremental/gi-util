module.exports = (mongoose, conf) ->
  port = parseInt conf.port

  opts =
    user: conf.username
    pass: conf.password

  mongoose.connect conf.host, conf.name, port, opts