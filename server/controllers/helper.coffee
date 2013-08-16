moment = require 'moment'

module.exports =

  getOptions: (req, model) ->
    options =
      query:
        systemId: req.systemId

    if req.gintFilter?
      #are there any restrictions on this model
      if req.gintFilter[model.name]
        options.query._id = req.gintFilter[model.name]

      #are there any parent restrictions we need
      #to take into account
      if model.relations?
        for parent in model.relations().parents
          if req.gintFilter[parent.modelName]
            options.query[parent.field] = req.gintFilter[parent.modelName]

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
        if v.indexOf('*and*') isnt -1
          options.query.$and = []

          splits = v.split '*and*'
          splits.forEach (split) ->
            if split.indexOf('|') isnt -1
              splits2 = split.split '|'
              switch splits2[0]
                when "lt"
                  obj = {}
                  obj[k] =
                    $lt: splits2[1]
                  options.query.$and.push obj
                when "ltdate"
                  date = moment(splits2[1]
                  , ["YYYY-MM-DD", "YYYY-MM-DDTHH:mm:ss"])
                  obj = {}
                  obj[k] =
                    $lt: date
                  options.query.$and.push obj
                when "lte"
                  obj = {}
                  obj[k] =
                    $lte: splits2[1]
                  options.query.$and.push obj
                when "gt"
                  obj = {}
                  obj[k] =
                    $gt: splits2[1]
                  options.query.$and.push obj
                when "gtdate"
                  date = moment(splits2[1]
                  , ["YYYY-MM-DD", "YYYY-MM-DDTHH:mm:ss"])
                  obj = {}
                  obj[k] =
                    $gt: date
                  options.query.$and.push obj
                when "gte"
                  obj = {}
                  obj[k] =
                    $gte: splits2[1]
                  options.query.$and.push obj
            else
              obj = {}
              obj[k] = split
              options.query.$and.push obj
        else
          options.query[k] = v

    options