require
  shim:
    'index': deps: ['../common/timePatterns']
    'services/crud': deps: ['index']
    'services/socket': deps: ['index']
  [
    'index'
    '../common/timePatterns'
    'services/crud'
    'services/socket'
  ], () ->
    return