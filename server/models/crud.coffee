module.exports = (Resource) ->

  find = (options, callback) ->
    max = options?.max or 10000
    sort = options?.sort or {}
    query = options?.query or {}
    if max < 1
      callback(null, []) if callback
    else
      Resource.find(query).sort(sort).limit(max).exec callback

  findById = (id, callback) ->
    Resource.findOne { _id : id}, (err, resource) ->
      if err
        callback err
      else if resource
        callback err, resource
      else
        callback 'Cannot find ' + Resource.modelName + ' with id: ' + id

  create = (json, callback) ->
    obj = new Resource json
    obj.save (err, resource) ->
      if err
        callback err
      else if resource
        callback err, resource
      else
        callback Resource.modelName + ' could not be saved'

  update = (id, json, callback) ->
    Resource.findByIdAndUpdate(id, json, callback)

  destroy =  (id, callback) ->
    Resource.findOne { _id : id}, (err, resource) ->
      if err
        callback err
      else
        resource.remove (err) ->
          callback err

  find: find
  findById: findById
  create: create
  update: update
  destroy: destroy
  name: Resource.name