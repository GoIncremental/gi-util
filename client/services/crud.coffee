angular.module('gi.util').factory 'giCrud'
, ['$resource', '$q', 'giSocket'
, ($resource, $q, Socket) ->

  factory = (resourceName, prefix, idField) ->

    if not prefix?
      prefix = '/api'

    if not idField?
      idField = '_id'

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

    bulkMethods =
      save:
        method: 'PUT'
        params: {}
        isArray: true

    queryMethods =
      query:
        method: 'POST'
        params: {}
        isArray: true

    bulkResource = $resource('/api/' + resourceName + '', {}, bulkMethods)
    resource = $resource('/api/' + resourceName + '/:id', {}, methods)
    queryResource = $resource('/api/' + resourceName + '/query', {}, queryMethods)

    items = []
    itemsById = {}

    updateMasterList = (newItem) ->
      replaced = false
      if angular.isArray newItem
        angular.forEach newItem, (newRec, i) ->
          # Nice quick check if the item already exists in the master list
          replaced = false
          if itemsById[newRec[idField]]?
            # Find and update
            angular.forEach items, (item, j) ->
              unless replaced
                if item[idField] is newRec[idField]
                  items[j] = newRec
                  replaced = true
          else
            items.push newRec
          itemsById[newRec[idField]] = newRec
        return
      else
        replaced = false
        angular.forEach items, (item, index) ->
          unless replaced
            if newItem[idField] is item[idField]
              replaced = true
              items[index] = newItem
        unless replaced
          items.push newItem
        itemsById[newItem[idField]] = newItem
        return

    all = (params) ->
      deferred = $q.defer()
      options = {}
      cacheable = true
      r = resource

      if not params? and items.length > 0
        deferred.resolve items
      else
        if params?
          cacheable = false

        options = params

        if params?.query?
          r = queryResource

        r.query options, (results) ->
          if cacheable
            items = results
            angular.forEach results, (item, index) ->
              itemsById[item[idField]] = item

          deferred.resolve results
        , (err) ->
          deferred.reject err

      deferred.promise

    save = (item) ->
      deferred = $q.defer()
      if angular.isArray item
        bulkResource.save {}, item, (result) ->
          updateMasterList result
          deferred.resolve result
        , (failure) ->
          deferred.reject failure
      else
        if item[idField]
          #we are updating
          resource.save {id: item[idField]}, item, (result) ->
            updateMasterList result
            deferred.resolve result
          , (failure) ->
            deferred.reject failure
        else
          #we are createing a new object on the server
          resource.create {}, item, (result) ->
            updateMasterList result
            deferred.resolve result
          , (failure) ->
            deferred.reject failure

      deferred.promise

    getCached = (id) ->
      return itemsById[id]

    allCached = () ->
      return items

    get = (id) ->
      deferred = $q.defer()
      resource.get {id: id}, (item) ->
        if items.length > 0
          updateMasterList item
        deferred.resolve item
      , (err) ->
        deferred.reject err

      deferred.promise

    destroy = (id) ->
      deferred = $q.defer()
      resource.delete {id: id}, () ->
        removed = false
        delete itemsById[id]
        angular.forEach items, (item, index) ->
          unless removed
             if item[idField] is id
              removed = true
              items.splice index, 1

        deferred.resolve()
      , (err) ->
        deferred.reject err

      deferred.promise

    count = () ->
      items.length

    clearCache = () ->
      items = []
      itemsById = {}

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
      cache: updateMasterList
      get: get
      getCached: getCached
      allCached: allCached
      destroy: destroy
      save: save
      count: count
      version: version
      clearCache: clearCache

    exports

  #export the crud factory method
  factory: factory
]
