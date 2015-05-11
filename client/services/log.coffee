angular.module('gi.util').provider 'giLog',
[ 'LogglyLoggerProvider', (LogglyLoggerProvider) ->
  prefix = ""

  @setLogglyToken = (token) ->
    if token?
      LogglyLoggerProvider.inputToken token

  @setLogglyTags = (tags) ->
    if tags?
      LogglyLoggerProvider.inputTag tags

  @setLogglyExtra = (extra) ->
    if extra?
      LogglyLoggerProvider.setExtra extra

    if extra.customer?
      prefix += extra.customer
    else
      prefix = "NO CUSTOMER"
    if extra.product?
      prefix += ":" + extra.product
    if extra.environment?
      prefix += ":" + extra.environment
    if extra.version?
      prefix += ":" + extra.version

    prefix += ": "

  wrap = (msg) ->
    if (typeof msg) is 'string'
      return prefix + msg
    else
      obj =
        prefix: prefix
        message: msg
      return obj

  @$get = ['$log', ($log) ->
    log: (msg) ->
      $log.log(wrap(msg))
    debug: (msg) ->
      $log.debug(wrap(msg))
    info: (msg) ->
      $log.info(wrap(msg))
    warn: (msg) ->
      $log.warn(wrap(msg))
    error: (msg) ->
      $log.warn(wrap(msg))
  ]

  @

]
