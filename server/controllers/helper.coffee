module.exports =

  getOptions: (req) ->
    options =
      query:
        systemId: req.systemId
    if req.gintFilter
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
        options.query[k] = v

    options