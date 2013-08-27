module.exports = (model) ->
  index: (req, res, next) ->
    options = {}
    model.find options, (err, result) ->
      if next
        res.gintResult = result
        next()
      else
        res.json 200, result
    
  update: (req, res, next) ->
    model.update req.params.id, req.body, (err, obj) ->
      if next
        res.gintResult = obj
        next()
      else
        res.json 200, obj
              
  destroy: () ->
  show: (req, res, next) ->
    model.findById req.params.id, req.systemId, (err, obj) ->
      if next
        res.gintResult = obj
        next()
      else
        res.json 200, obj

  create: (req, res, next) ->
    model.create req.body, (err, obj) ->
      if next
        res.gintResult = obj
        next()
      else
        res.json 200, obj