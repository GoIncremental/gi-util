angular.module('gi.util').factory 'giUtil'
, [ () ->
  emailRegex: /^[0-9a-zA-Z][-0-9a-zA-Z.+_]*@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}$/
]
