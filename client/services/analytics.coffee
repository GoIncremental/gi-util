angular.module('gi.util').provider 'giAnalytics', () ->
  google = null
  enhancedEcommerce = false
  if ga?
    google = ga

  @$get = [ 'giLog', (Log) ->
    requireGaPlugin = (x) ->
      Log.debug('ga requiring ' + x)
      if google?
        google 'require', x

    sendImpression = (obj) ->
      if google? and obj?
        if not enhancedEcommerce
          requireGaPlugin 'ec'

        Log.debug('ga sending impression ' + obj.name)
        google 'ec:addImpression', obj

    sendPageView = () ->
      if google?
        Log.debug('ga sending page view')
        google 'send', 'pageview'

    sendAddToCart = (obj) ->
      if google? and obj?
        if not enhancedEcommerce
          requireGaPlugin 'ec'

        ga('ec:addProduct', obj )
        ga('ec:setAction', 'add', {list: obj.category})
        ga('send', 'event', 'UX', 'click', 'add to cart')

    sendDetailView = (obj) ->
      if google? and obj?
        if not enhancedEcommerce
          requireGaPlugin 'ec'

        sendPageView()
        ga('ec:addImpression', obj )
        ga('send', 'event', 'Detail', 'click', 'View Detail: ' + obj.id , 1);


    sendDetailView: sendDetailView
    Impression: sendImpression
    PageView: sendPageView
    sendAddToCart: sendAddToCart
  ]

  @
