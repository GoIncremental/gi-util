util = require 'util'
module.exports = (Resource) ->

  find = (options, callback) ->
    if options? and options.max?
      max = options.max
    else
      max = 10000

    if options? and options.sort?
      sort = options.sort
    else
      sort = {}

    if options? and options.page?
      page = options.page
    else
      page = 1

    if options? and options.query?
      query = options.query
    else
      query = {}
    
    skipFrom = page * max - max

    if max < 1
      callback(null, []) if callback
    else
      command = Resource.find(query).sort(sort).skip(skipFrom).limit(max)
      command.exec (err, results) ->
        if err
          callback err, null, 0
        else
          Resource.count query, (err, count) ->
            if err
              callback 'could not count the results', null, 0
            else
              #safe because max >= 1
              pageCount = Math.ceil(count/max)
              callback null, results, pageCount
 
  findOneBy = (key, value, callback) ->
    params = {}
    params[key] = value
    Resource.findOne params, (err, resource) ->
      if err
        callback err
      else if resource
        callback err, resource
      else
        callback 'Cannot find ' + Resource.name + ' with ' + key + ': ' + value
  
  findById = (id, callback) ->
    findOneBy '_id',id, callback

  create = (json, callback) ->
    obj = new Resource json
    obj.save (err, resource) ->
      if err
        callback err
      else if resource
        callback null, resource
      else
        callback Resource.name + ' could not be saved'

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
  findOneBy: findOneBy
  create: create
  update: update
  destroy: destroy
  name: Resource.name