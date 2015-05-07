angular.module('gi.util').provider 'giAnalytics', () ->
  google = null
  enhancedEcommerce = false
  if ga?
    google = ga

  @$get = [ 'giLog', (Log) ->
    requireGaPlugin = (x) ->
      Log.log('ga requiring ' + x)
      if google?
        google 'require', x

    sendImpression = (obj) ->
      if google?
        if not enhancedEcommerce
          requireGaPlugin 'ec'
        Log.log('ga sending impression')
        Log.log(obj)
        google 'ec:addImpression', obj

    sendPageView = () ->
      Log.log('ga sending page view')
      google 'send', 'pageview'

    Impression: sendImpression
    PageView: sendPageView
  ]

  @
