module.exports = (model) ->

  create = (req, res, callback) ->
    model.create req.body, (err, obj) ->
      if err
        res.json 500, {error: err.toString()}
      else
        if callback
          callback null, obj
        else
          res.json 200, obj
  update = (req, res, callback) ->
    if req.params.id

      # wierdly, mongoose doesn't work if you put an id
      # in the update payload
      payload = req.body
      if req.body._id
        delete payload._id

      model.update req.params.id, payload, (err, obj) ->
        if err
          res.json 400
        else
          if callback
            callback null, obj
          else
            res.json 200, obj
    else
      res.json 400

  destroy = (req, res) ->
    if req.params?.id
      model.destroy req.params.id, (err) ->
        if err
          res.json 404
        else
          res.json 200
    else
      res.json 404

  show = (req, res, callback) ->
    if req.params?.id
      model.findById req.params.id, (err, obj) ->
        if err
          res.json 404
        else if obj
          if callback
            callback null, obj
          else
            res.json 200, obj
        else
          res.json 404
    else
      res.json 404

  index = (req, res, callback) ->
   
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
      if callback
        callback err, result
      else
        if err
          res.json 404, err
        else
          res.json 200, result

  index: index
  create: create
  show: show
  update: update
  destroy: destroy