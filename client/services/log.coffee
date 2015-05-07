angular.module('gi.util').provider 'giLog',
[ 'LogglyLoggerProvider', (LogglyLoggerProvider) ->

  @setLogglyToken = (token) ->
    if token?
      LogglyLoggerProvider.inputToken token

  @$get = ['$log', ($log) ->
    $log
  ]

  @

]
