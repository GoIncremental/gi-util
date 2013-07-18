noCache = (req, res, next) ->
  #for the benefit of IE9 - which insists on caching
  #all of my requests
  res.set "Cache-Control", "max-age=0,no-cache,no-store"
  next()

exports.noCache = noCache