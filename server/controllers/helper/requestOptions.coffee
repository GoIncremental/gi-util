splitter = require './querySplitter'

module.exports =
  getOptions: (req, model) ->
    options =
      query:
        systemId: req.systemId

    if req.giFilter?
      #are there any restrictions on this model
      if req.giFilter[model.name]
        options.query._id = req.giFilter[model.name]

      #are there any parent restrictions we need
      #to take into account
      if model.relations?
        for parent in model.relations().parents
          if req.giFilter[parent.modelName]
            options.query[parent.field] = req.giFilter[parent.modelName]

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
          splits = v.split '*and*'
          options.query.$and = (x for x in splitter.processSplits(splits, k))
        else if v.indexOf('*or*') isnt -1
          splits = v.split '*or*'
          options.query.$or = (x for x in splitter.processSplits(splits, k))
        else
          options.query[k] = splitter.processSplit v, k

    options