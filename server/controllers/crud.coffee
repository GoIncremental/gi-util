helper = require './helper'

module.exports = (model) ->

  index = (req, res, next) ->
    options = helper.getOptions req, model

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

  create = (req, res, next) ->
    req.body.systemId = req.systemId
    model.create req.body, (err, obj) ->
      if err
        res.json 500, {error: err.toString()}
      else
        if next
          res.gintResult = obj
          next()
        else
          res.json 200, obj

  show = (req, res, next) ->
    if req.params?.id and req.systemId
      model.findById req.params.id, req.systemId, (err, obj) ->
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

  update = (req, res, next) ->
    if req.params?.id and req.systemId
      req.body.systemId = req.systemId
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
      res.json 400

  destroy = (req, res, next) ->
    if req.params?.id and req.systemId
      model.destroy req.params.id, req.systemId, (err) ->
        if err
          res.json 400, {message: err}
        else
          if next
            res.gintResult = 'Ok'
            next()
          else
            res.json 200
    else
      res.json 404

  count = (req, res, next) ->
    options = helper.getOptions req, model

    model.count options.query
    , (err, result) ->
      if err
        res.json 404, {message: err}
      else
        if next
          res.gintResult = {count: result}
          next()
        else
          res.json 200, result

  name: model.name
  index: index
  create: create
  show: show
  update: update
  destroy: destroy
  count: count