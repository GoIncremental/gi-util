angular.module('gi.util').factory 'giCrud'
, ['$resource', '$q', 'giSocket'
, ($resource, $q, Socket) ->

  formDirectiveFactory = (name, Model) ->
    lowerName = name.toLowerCase()
    formName = lowerName + 'Form'

    restrict: 'E'
    scope:
      submitText: '@'
      model: '='
    templateUrl: 'gi.commerce.' + formName + '.html'
    link:
      pre: ($scope) ->
        $scope.save = () ->
          $scope.model.selectedItem.acl = "public-read"
          Model.save($scope.model.selectedItem).then () ->
            alert =
              name: lowerName + '-saved'
              type: 'success'
              msg: name + " Saved."

            $scope.$emit 'event:show-alert', alert
            $scope.$emit lowerName + '-saved', $scope.model.selectedItem
            $scope.clear()
          , (err) ->
            alert =
              name: lowerName + '-not-saved'
              type: 'danger'
              msg: "Failed to save " + name + ". " + err.data.error
            $scope.$emit 'event:show-alert',alert

        $scope.clear = () ->
          $scope.model.selectedItem = {}
          $scope[formName].$setPristine()
          $scope.confirm = false
          $scope.$emit lowerName + '-form-cleared'

        $scope.destroy = () ->
          if $scope.confirm
            Model.destroy($scope.model.selectedItem._id).then () ->
              alert =
                name: lowerName + '-deleted'
                type: 'success'
                msg: name + ' Deleted.'
              $scope.$emit 'event:show-alert', alert
              $scope.$emit lowerName + '-deleted'
              $scope.clear()
            , () ->
              alert =
                name: name + " not deleted"
                msg: name + " not deleted."
                type: "warning"
              $scope.$emit 'event:show-alert', alert
              $scope.confirm = false
          else
            $scope.confirm = true

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

    bulkResource = $resource(prefix + '/' + resourceName + '', {}, bulkMethods)
    resource = $resource(prefix + '/' + resourceName + '/:id', {}, methods)
    queryResource = $resource(prefix + '/' + resourceName + '/query'
    , {}, queryMethods)

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
  formDirectiveFactory: formDirectiveFactory
]
