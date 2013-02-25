module.exports = (model) ->

  create = (req, res) ->
    model.create req.body, (err, obj) ->
      if err
        res.json 500
      else
        res.json 200, obj
  update = (req, res) ->
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

  read = (req, res) ->
    if req.params?.id
      model.findById req.params.id, (err, obj) ->
        if err
          res.json 404
        else if obj
          res.json 200, obj
        else
          res.json 404
    else
      res.json 404

  index = (req, res) ->
   
    options = 
      query: {}

    for k,v of req.query
      if k is 'max'
        if not isNaN(v)
          if v < 1
            options.max = 0
          else
            options.max = v
      else
        options.query[k] = v

    model.find options
    , (err, result) ->
      if err
        res.json 404, err
      else
        res.json 200, result

  index: index
  create: create
  show: read
  update: update
  destroy: destroy