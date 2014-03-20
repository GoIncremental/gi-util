angular.module('gi.util').factory 'giCrud'
, ['$resource', '$q', 'giSocket'
, ($resource, $q, Socket) ->

  factory = (resourceName, usePromises) ->
    methods =
      query:
        method: 'GET'
        params: {}
        isArray: true
      save:
        method: 'PUT'
        params: {}
        isArray: false
      create:
        method: 'POST'
        params: {}
        isArray: false

    resource = $resource('/api/' + resourceName + '/:id', {}, methods)

    items = []
    itemsById = {}

    updateMasterList = (newItem) ->
      replaced = false
      angular.forEach items, (item, index) ->
        unless replaced
          if newItem._id is item._id
            replaced = true
            items[index] = newItem
      unless replaced
        items.push newItem
      itemsById[newItem._id] = newItem
      return

    all = (params, callback) ->
      options = {}
      cacheable = true
      if _.isFunction(params)
        callback = params
        if items.length > 0
          callback items if callback
          return
      else
        cacheable = false
        options = params

      resource.query options, (results) ->
        if cacheable
          items = results
          angular.forEach results, (item, index) ->
            itemsById[item._id] = item
            return

        callback results if callback

    allPromise = (params) ->
      deferred = $q.defer()
      if params
        all params, (results) ->
          deferred.resolve results
      else
        all (results) ->
          deferred.resolve results
      
      deferred.promise

    save = (item, success, fail) ->
      if item._id
        #we are updating
        resource.save {id: item._id}, item, (result) ->
          updateMasterList result
          success(result) if success
        , (failure) ->
          fail(failure) if fail

      else
        #we are createing a new object on the server
        resource.create {}, item, (result) ->
          updateMasterList result
          success(result) if success
        , (failure) ->
          fail(failure) if fail

    savePromise = (item) ->
      deferred = $q.defer()
      save item, (res) ->
        deferred.resolve res
      , (err) ->
        deferred.reject err

      deferred.promise

    getCached = (id) ->
      return itemsById[id]

    allCached = () ->
      return items

    get = (id, callback) ->
      resource.get {id: id}, (item) ->
        if items.length > 0
          updateMasterList item
        callback item if callback
    
    getPromise = (id) ->
      deferred = $q.defer()
      get id, (item) ->
        deferred.resolve item

      deferred.promise
    
    destroy = (id, callback) ->
      resource.delete {id: id}, () ->
        removed = false
        delete itemsById[id]
        angular.forEach items, (item, index) ->
          unless removed
             if item._id is id
              removed = true
              items.splice index, 1
              
        callback() if callback
    
    destroyPromise = (id) ->
      deferred = $q.defer()
      destroy id, () ->
        deferred.resolve()
      deferred.promise

    count = () ->
      items.length

    Socket.emit 'watch:' + resourceName

    Socket.on resourceName + '_created', (data) ->
      updateMasterList data
      _version += 1
    
    Socket.on resourceName + '_updated', (data) ->
      updateMasterList data
      _version += 1

    _version = 0
    version = () ->
      _version
    
    exports =
      query: all
      all: all
      get: get
      getCached: getCached
      allCached: allCached
      destroy: destroy
      save: save
      count: count
      version: version

    if usePromises
      exports.all = allPromise
      exports.query = allPromise
      exports.get = getPromise
      exports.save = savePromise
      exports.destroy = destroyPromise

    exports

  #export the crud factory method
  factory: factory
]