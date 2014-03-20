angular.module('gi.util').factory 'giSocket'
, ['$rootScope'
, ($rootScope) ->
  socket = io.connect() if io?
  on: (eventName, callback) ->
    if io?
      socket.on eventName, () ->
        # This is some javascript magic proto inheritance maybe?
        # Tried taking it out and it breaks, but no idea where
        # the arguments variable comes from
        args = arguments
        if callback
          $rootScope.$apply () ->
            callback.apply socket, args

  emit: (eventName, data, callback) ->
    if io?
      socket.emit eventName, data, () ->
        args = arguments
        if callback
          $rootScope.$apply () ->
            callback.apply socket, args
]