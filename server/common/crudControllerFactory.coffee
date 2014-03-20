helper = require '../controllers/helper'
_ = require 'underscore'
async = require 'async'

module.exports = (model) ->

  index = (req, res, next) ->
    options = helper.getOptions req, model

    model.find options
    , (err, result, pageCount) ->
      if err
        res.json 404, err
      else
        if next
          res.giResult = result
          next()
        else
          res.json 200, result


  create = (req, res, next) ->
    if _.isArray req.body
      errors = []
      results = []
      async.each req.body, (obj, cb) ->
        obj.systemId = req.systemId
        model.create obj, (err, result) ->
          if err
            errors.push {message: err, obj: obj}
            cb()
          else if result
            results.push {message: "ok", obj: obj}
            cb()
          else
            errors.push {message: "create failed for reasons unknown", obj: obj}
            cb()
      , () ->
        resultCode = 200
        if errors.length > 0
          resultCode = 500
        if next
          res.giResult = errors.concat results
          res.giResultCode = resultCode
          next()
        else
          res.json resultCode, errors.concat results

    else
      req.body.systemId = req.systemId
      model.create req.body, (err, obj) ->
        if err
          res.json 500, {error: err.toString()}
        else
          if next
            res.giResult = obj
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
            res.giResult = obj
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
            res.giResult = obj
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
            res.giResult = 'Ok'
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
          res.giResult = {count: result}
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