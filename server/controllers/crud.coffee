module.exports = (model) ->
  create = (req, res, next) ->
    model.create req.body, (err, obj) ->
      if err
        res.json 500, {error: err.toString()}
      else
        if next
          res.gintResult = obj
          next()
        else
          res.json 200, obj
  update = (req, res, next) ->
    if req.params.id

      # wierdly, mongoose doesn't work if you put an id
      # in the update payload
      payload = req.body
      if req.body._id
        delete payload._id

      model.update req.params.id, payload, (err, obj) ->
        if err
          res.json 400, {message: err}
        else
          if next
            res.gintResult = obj
            next()
          else
            res.json 200, obj
    else
      res.json 400, {message: 'No Id specified'}

  destroy = (req, res, next) ->
    if req.params?.id
      model.destroy req.params.id, (err) ->
        if err
          res.json 404
        else
          if next
            res.gintResult = 'Ok'
            next()
          else
            res.json 200
    else
      res.json 404

  show = (req, res, next) ->
    if req.params?.id
      model.findById req.params.id, (err, obj) ->
        if err
          res.json 404
        else if obj
          if next
            res.gintResult = obj
            next()
          else
            res.json 200, obj
        else
          res.json 404
    else
      res.json 404

  index = (req, res, next) ->
   
    options =
      query: {}

    for k,v of req.query
      if k is 'max'
        if not isNaN(v)
          if v < 1
            options.max = 0
          else
            options.max = v
      else if k is 'sort'
        options.sort = v
      else if k is 'page'
        options.page = v
      else
        options.query[k] = v

    model.find options
    , (err, result, pageCount) ->
      if err
        res.json 404, err
      else
        if next
          res.gintResult = result
          next()
        else
          res.json 200, result

  name: model.name
  index: index
  create: create
  show: show
  update: update
  destroy: destroy