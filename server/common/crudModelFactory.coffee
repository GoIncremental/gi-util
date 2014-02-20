module.exports = (Resource) ->
  count = (query, callback) ->
    if not query.systemId?
      callback 'Cannot count ' +
      Resource.modelName + '- no SystemId', null
    else
      Resource.count query, (err, count) ->
        if err
          callback 'could not count the results', -1
        else
          callback null, count

  find = (options, callback) ->
    if options?
      if options.max?
        max = options.max
      else
        max = 10000

      if options.sort?
        sort = options.sort
      else
        sort = {}

      if options.page?
        page = options.page
      else
        page = 1

      if options.query? and options.query.systemId?
        query = options.query
      else
        callback('systemId not specified in query', null, 0) if callback
        return
    else
      callback('options must be specfied for find', null, 0) if callback
      return
    
    skipFrom = page * max - max

    if max < 1
      callback(null, [], 0) if callback
    else
      command = Resource.find(query).sort(sort).skip(skipFrom).limit(max)
      command.exec (err, results) ->
        if err
          callback err, null, 0
        else
          Resource.count query, (err, count) ->
            if err
              callback('could not count the results', null, 0) if callback
            else
              #safe because max >= 1
              pageCount = Math.ceil(count/max) or 0
              callback(null, results, pageCount) if callback
 
  findOne = (query, callback) ->
    if not query? or not query.systemId?
      callback 'Cannot find ' +
      Resource.modelName + ' - no SystemId', null
    else
      Resource.findOne query, (err, resource) ->
        if err
          callback(err) if callback
        else if resource
          callback(null, resource) if callback
        else
          callback('Cannot find ' + Resource.modelName) if callback

  findOneBy = (key, value, systemId, callback) ->
    query =
      systemId: systemId
    query[key] = value

    @findOne query, callback
  
  findById = (id, systemId, callback) ->
    @findOneBy '_id', id, systemId, callback

  create = (json, callback) ->
    if not json.systemId?
      callback Resource.modelName  + ' could not be created - no systemId'
    else
      Resource.create json, (err, resource) ->
        if err
          callback err
        else if resource
          callback null, resource
        else
          callback Resource.modelName + ' could not be saved'

  update = (id, json, callback) ->
    if not json.systemId?
      callback Resource.modelName + ' could not be updated - no systemId'
    else
      Resource.findByIdAndUpdate(id, json, callback)

  destroy =  (id, systemId, callback) ->
    if not systemId?
      callback 'Could not destroy ' + Resource.modelName + ' - no systemId'
    else
      Resource.findOne { _id : id, systemId: systemId}, (err, resource) ->
        if err
          callback err
        else if resource
          Resource.remove {_id: resource._id, systemId: systemId}, callback
        else
          callback null
  
  find: find
  findById: findById
  findOne: findOne
  findOneBy: findOneBy
  create: create
  update: update
  destroy: destroy
  name: Resource.modelName
  count: count