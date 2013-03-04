noCache = (req, res, next) ->
  #for the benefit of IE9 - which insists on caching
  #all of my requests
  res.set "Cache-Control", "max-age=0,no-cache,no-store"
  next()

enforceDotCloudSSL = (req, res, next) ->
  #determine whether the connection is secure
  if req.get('X-Forwarded-Port') is '443'
    console.log 'request is secure'
    next()
  else
    redirectUri = 'https://' + req.host + req.path
    console.log 'request is insecure redirecting to : ' + redirectUri
    res.redirect redirectUri
    
exports.noCache = noCache
exports.enforceSSL = enforceDotCloudSSL