angular.module('gi.util', ['ngResource', 'ngCookies', 'logglyLogger', 'ngTouch', 'ngRoute', 'ng.deviceDetector']).value('version', '1.9.5').config([
  'giLogProvider', function(giLogProvider) {
    if (typeof loggly !== "undefined" && loggly !== null) {
      giLogProvider.setLogglyToken(loggly.key);
      giLogProvider.setLogglyTags("angular," + loggly.tags);
      return giLogProvider.setLogglyExtra(loggly.extra);
    }
  }
]);

angular.module('gi.util').directive('giMatch', [
  '$parse', 'giLog', function($parse, Log) {
    return {
      require: '?ngModel',
      restrict: 'A',
      link: function(scope, elem, attrs, ctrl) {
        var evaluateMatch, getMatchValue, isRequired, matchGetter, requiredGetter;
        if (!ctrl) {
          Log.warn('giMatch validation requires ngModel to be on the element');
          return;
        } else {
          Log.debug('giMatch linked');
        }
        matchGetter = $parse(attrs.giMatch);
        requiredGetter = $parse(attrs.ngRequired);
        evaluateMatch = function() {
          return getMatchValue();
        };
        scope.$watch(evaluateMatch, function(newVal) {
          return ctrl.$$parseAndValidate();
        });
        ctrl.$validators.giMatch = function() {
          var match;
          if (requiredGetter(scope)) {
            match = getMatchValue();
            if (match != null) {
              return ctrl.$viewValue === match;
            } else {
              return true;
            }
          } else {
            return true;
          }
        };
        isRequired = function() {
          return requiredGetter(scope);
        };
        return getMatchValue = function() {
          var match;
          match = matchGetter(scope);
          if (angular.isObject(match) && match.hasOwnProperty('$viewValue')) {
            match = match.$viewValue;
          }
          return match;
        };
      }
    };
  }
]);

angular.module('gi.util').provider('giAnalytics', function() {
  var enhancedEcommerce, google;
  google = null;
  enhancedEcommerce = false;
  if (typeof ga !== "undefined" && ga !== null) {
    google = ga;
  }
  this.$get = [
    'giLog', function(Log) {
      var requireGaPlugin, sendAddToCart, sendDetailView, sendImpression, sendPageView;
      requireGaPlugin = function(x) {
        Log.debug('ga requiring ' + x);
        if (google != null) {
          return google('require', x);
        }
      };
      sendImpression = function(obj) {
        if ((google != null) && (obj != null)) {
          if (!enhancedEcommerce) {
            requireGaPlugin('ec');
          }
          Log.debug('ga sending impression ' + obj.name);
          return google('ec:addImpression', obj);
        }
      };
      sendPageView = function() {
        if (google != null) {
          Log.debug('ga sending page view');
          return google('send', 'pageview');
        }
      };
      sendAddToCart = function(obj) {
        if ((google != null) && (obj != null)) {
          if (!enhancedEcommerce) {
            requireGaPlugin('ec');
          }
          ga('ec:addProduct', obj);
          ga('ec:setAction', 'add', {
            list: obj.category
          });
          return ga('send', 'event', 'UX', 'click', 'add to cart');
        }
      };
      sendDetailView = function(obj) {
        if ((google != null) && (obj != null)) {
          if (!enhancedEcommerce) {
            requireGaPlugin('ec');
          }
          sendPageView();
          ga('ec:addImpression', obj);
          return ga('send', 'event', 'Detail', 'click', 'View Detail: ' + obj.id, 1);
        }
      };
      return {
        sendDetailView: sendDetailView,
        Impression: sendImpression,
        PageView: sendPageView,
        sendAddToCart: sendAddToCart
      };
    }
  ];
  return this;
});

angular.module('gi.util').factory('giCrud', [
  '$resource', '$q', 'giSocket', function($resource, $q, Socket) {
    var factory, formDirectiveFactory;
    formDirectiveFactory = function(name, Model) {
      var formName, lowerName;
      lowerName = name.toLowerCase();
      formName = lowerName + 'Form';
      return {
        restrict: 'E',
        scope: {
          submitText: '@',
          model: '='
        },
        templateUrl: 'gi.commerce.' + formName + '.html',
        link: {
          pre: function($scope) {
            $scope.save = function() {
              $scope.model.selectedItem.acl = "public-read";
              return Model.save($scope.model.selectedItem).then(function() {
                var alert;
                alert = {
                  name: lowerName + '-saved',
                  type: 'success',
                  msg: name + " Saved."
                };
                $scope.$emit('event:show-alert', alert);
                $scope.$emit(lowerName + '-saved', $scope.model.selectedItem);
                return $scope.clear();
              }, function(err) {
                var alert;
                alert = {
                  name: lowerName + '-not-saved',
                  type: 'danger',
                  msg: "Failed to save " + name + ". " + err.data.error
                };
                return $scope.$emit('event:show-alert', alert);
              });
            };
            $scope.clear = function() {
              $scope.model.selectedItem = {};
              $scope[formName].$setPristine();
              $scope.confirm = false;
              return $scope.$emit(lowerName + '-form-cleared');
            };
            return $scope.destroy = function() {
              if ($scope.confirm) {
                return Model.destroy($scope.model.selectedItem._id).then(function() {
                  var alert;
                  alert = {
                    name: lowerName + '-deleted',
                    type: 'success',
                    msg: name + ' Deleted.'
                  };
                  $scope.$emit('event:show-alert', alert);
                  $scope.$emit(lowerName + '-deleted');
                  return $scope.clear();
                }, function() {
                  var alert;
                  alert = {
                    name: name + " not deleted",
                    msg: name + " not deleted.",
                    type: "warning"
                  };
                  $scope.$emit('event:show-alert', alert);
                  return $scope.confirm = false;
                });
              } else {
                return $scope.confirm = true;
              }
            };
          }
        }
      };
    };
    factory = function(resourceName, prefix, idField) {
      var _version, all, allCached, bulkMethods, bulkResource, clearCache, count, destroy, exports, get, getCached, items, itemsById, methods, queryMethods, queryResource, resource, save, updateMasterList, version;
      if (prefix == null) {
        prefix = '/api';
      }
      if (idField == null) {
        idField = '_id';
      }
      methods = {
        query: {
          method: 'GET',
          params: {},
          isArray: true
        },
        save: {
          method: 'PUT',
          params: {},
          isArray: false
        },
        create: {
          method: 'POST',
          params: {},
          isArray: false
        }
      };
      bulkMethods = {
        save: {
          method: 'PUT',
          params: {},
          isArray: true
        }
      };
      queryMethods = {
        query: {
          method: 'POST',
          params: {},
          isArray: true
        }
      };
      bulkResource = $resource(prefix + '/' + resourceName + '', {}, bulkMethods);
      resource = $resource(prefix + '/' + resourceName + '/:id', {}, methods);
      queryResource = $resource(prefix + '/' + resourceName + '/query', {}, queryMethods);
      items = [];
      itemsById = {};
      updateMasterList = function(newItem) {
        var replaced;
        replaced = false;
        if (angular.isArray(newItem)) {
          angular.forEach(newItem, function(newRec, i) {
            replaced = false;
            if (itemsById[newRec[idField]] != null) {
              angular.forEach(items, function(item, j) {
                if (!replaced) {
                  if (item[idField] === newRec[idField]) {
                    items[j] = newRec;
                    return replaced = true;
                  }
                }
              });
            } else {
              items.push(newRec);
            }
            return itemsById[newRec[idField]] = newRec;
          });
        } else {
          replaced = false;
          angular.forEach(items, function(item, index) {
            if (!replaced) {
              if (newItem[idField] === item[idField]) {
                replaced = true;
                return items[index] = newItem;
              }
            }
          });
          if (!replaced) {
            items.push(newItem);
          }
          itemsById[newItem[idField]] = newItem;
        }
      };
      all = function(params) {
        var cacheable, deferred, options, r;
        deferred = $q.defer();
        options = {};
        cacheable = true;
        r = resource;
        if ((params == null) && items.length > 0) {
          deferred.resolve(items);
        } else {
          if (params != null) {
            cacheable = false;
          }
          options = params;
          if ((params != null ? params.query : void 0) != null) {
            r = queryResource;
          }
          r.query(options, function(results) {
            if (cacheable) {
              items = results;
              angular.forEach(results, function(item, index) {
                return itemsById[item[idField]] = item;
              });
            }
            return deferred.resolve(results);
          }, function(err) {
            return deferred.reject(err);
          });
        }
        return deferred.promise;
      };
      save = function(item) {
        var deferred;
        deferred = $q.defer();
        if (angular.isArray(item)) {
          bulkResource.save({}, item, function(result) {
            updateMasterList(result);
            return deferred.resolve(result);
          }, function(failure) {
            return deferred.reject(failure);
          });
        } else {
          if (item[idField]) {
            resource.save({
              id: item[idField]
            }, item, function(result) {
              updateMasterList(result);
              return deferred.resolve(result);
            }, function(failure) {
              return deferred.reject(failure);
            });
          } else {
            resource.create({}, item, function(result) {
              updateMasterList(result);
              return deferred.resolve(result);
            }, function(failure) {
              return deferred.reject(failure);
            });
          }
        }
        return deferred.promise;
      };
      getCached = function(id) {
        return itemsById[id];
      };
      allCached = function() {
        return items;
      };
      get = function(id) {
        var deferred;
        deferred = $q.defer();
        resource.get({
          id: id
        }, function(item) {
          if (items.length > 0) {
            updateMasterList(item);
          }
          return deferred.resolve(item);
        }, function(err) {
          return deferred.reject(err);
        });
        return deferred.promise;
      };
      destroy = function(id) {
        var deferred;
        deferred = $q.defer();
        resource["delete"]({
          id: id
        }, function() {
          var removed;
          removed = false;
          delete itemsById[id];
          angular.forEach(items, function(item, index) {
            if (!removed) {
              if (item[idField] === id) {
                removed = true;
                return items.splice(index, 1);
              }
            }
          });
          return deferred.resolve();
        }, function(err) {
          return deferred.reject(err);
        });
        return deferred.promise;
      };
      count = function() {
        return items.length;
      };
      clearCache = function() {
        items = [];
        return itemsById = {};
      };
      Socket.emit('watch:' + resourceName);
      Socket.on(resourceName + '_created', function(data) {
        updateMasterList(data);
        return _version += 1;
      });
      Socket.on(resourceName + '_updated', function(data) {
        updateMasterList(data);
        return _version += 1;
      });
      _version = 0;
      version = function() {
        return _version;
      };
      exports = {
        query: all,
        all: all,
        cache: updateMasterList,
        get: get,
        getCached: getCached,
        allCached: allCached,
        destroy: destroy,
        save: save,
        count: count,
        version: version,
        clearCache: clearCache
      };
      return exports;
    };
    return {
      factory: factory,
      formDirectiveFactory: formDirectiveFactory
    };
  }
]);

angular.module('gi.util').factory('giGeo', [
  '$q', '$http', '$cookieStore', function($q, $http, $cookies) {
    var cookieID;
    cookieID = "giGeo";
    return {
      country: function() {
        var deferred, geoInfo;
        deferred = $q.defer();
        geoInfo = $cookies.get(cookieID);
        if (geoInfo == null) {
          $http.get("/api/geoip").success(function(info) {
            $cookies.put(cookieID, info);
            return deferred.resolve(info.country_code);
          }).error(function(data) {
            return deferred.reject(data);
          });
        } else {
          deferred.resolve(geoInfo.country_code);
        }
        return deferred.promise;
      }
    };
  }
]);

angular.module('gi.util').provider('giI18n', [
  function() {
    var countries, defaultCountryCode;
    countries = {};
    defaultCountryCode = "ROW";
    this.setMessagesForCountry = function(messages, countryCode) {
      if (countries[countryCode] == null) {
        countries[countryCode] = {};
      }
      return angular.forEach(messages, function(msg) {
        return countries[countryCode][msg.key] = msg.value;
      });
    };
    this.setDefaultCountry = function(countryCode) {
      return defaultCountryCode = countryCode;
    };
    this.$get = [
      function() {
        var messages;
        messages = countries[defaultCountryCode];
        return {
          setCountry: function(countryCode) {
            if (countries[countryCode] != null) {
              return messages = countries[countryCode];
            } else if (countries[defaultCountryCode] != null) {
              return messages = countries[defaultCountryCode];
            }
          },
          getMessage: function(messageKey) {
            return messages[messageKey] || "";
          },
          getCapitalisedMessage: function(messageKey) {
            var msg;
            msg = messages[messageKey];
            if (msg != null) {
              return msg.charAt(0).toUpperCase() + msg.slice(1);
            } else {
              return "";
            }
          }
        };
      }
    ];
    return this;
  }
]);

angular.module('gi.util').factory('giLocalStorage', [
  '$window', function($window) {
    return {
      get: function(key) {
        if ($window.localStorage[key]) {
          return angular.fromJson($window.localStorage[key]);
        } else {
          return false;
        }
      },
      set: function(key, val) {
        if (val == null) {
          $window.localStorage.removeItem(key);
        } else {
          $window.localStorage[key] = angular.toJson(val);
        }
        return $window.localStorage[key];
      }
    };
  }
]);

angular.module('gi.util').provider('giLog', [
  'LogglyLoggerProvider', function(LogglyLoggerProvider) {
    var prefix, wrap;
    prefix = "";
    this.setLogglyToken = function(token) {
      if (token != null) {
        return LogglyLoggerProvider.inputToken(token);
      }
    };
    this.setLogglyTags = function(tags) {
      if (tags != null) {
        return LogglyLoggerProvider.inputTag(tags);
      }
    };
    this.setLogglyExtra = function(extra) {
      if (extra != null) {
        LogglyLoggerProvider.setExtra(extra);
      }
      if (extra.customer != null) {
        prefix += extra.customer;
      } else {
        prefix = "NO CUSTOMER";
      }
      if (extra.product != null) {
        prefix += ":" + extra.product;
      }
      if (extra.environment != null) {
        prefix += ":" + extra.environment;
      }
      if (extra.version != null) {
        prefix += ":" + extra.version;
      }
      return prefix += ": ";
    };
    wrap = function(msg) {
      var obj;
      if ((typeof msg) === 'string') {
        return prefix + msg;
      } else {
        obj = {
          prefix: prefix,
          message: msg
        };
        return obj;
      }
    };
    this.$get = [
      '$log', function($log) {
        return {
          log: function(msg) {
            return $log.log(wrap(msg));
          },
          debug: function(msg) {
            return $log.debug(wrap(msg));
          },
          info: function(msg) {
            return $log.info(wrap(msg));
          },
          warn: function(msg) {
            return $log.warn(wrap(msg));
          },
          error: function(msg) {
            return $log.warn(wrap(msg));
          }
        };
      }
    ];
    return this;
  }
]);

angular.module('gi.util').factory('giSocket', [
  '$rootScope', function($rootScope) {
    var socket;
    if (typeof io !== "undefined" && io !== null) {
      socket = io.connect();
    }
    return {
      on: function(eventName, callback) {
        if (typeof io !== "undefined" && io !== null) {
          return socket.on(eventName, function() {
            var args;
            args = arguments;
            if (callback) {
              return $rootScope.$apply(function() {
                return callback.apply(socket, args);
              });
            }
          });
        }
      },
      emit: function(eventName, data, callback) {
        if (typeof io !== "undefined" && io !== null) {
          return socket.emit(eventName, data, function() {
            var args;
            args = arguments;
            if (callback) {
              return $rootScope.$apply(function() {
                return callback.apply(socket, args);
              });
            }
          });
        }
      }
    };
  }
]);

var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('gi.util').factory('giUtil', [
  function() {
    return {
      emailRegex: /^[0-9a-zA-Z][-0-9a-zA-Z.+_]*@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}$/,
      vatRegex: /^(AT|BE|BG|CY|CZ|DE|DK|EE|EL|ES|FI|FR|GB|HU|IE|IT|LT|LU|LV|MT|NL|PL|PT|SE|SI|SK|RO)(\w{8,12})$/,
      countrySort: function(topCodes) {
        return function(country) {
          var index, ref;
          if ((country != null ? country.code : void 0) != null) {
            index = (ref = country.code, indexOf.call(topCodes, ref) >= 0);
            if (index) {
              return topCodes.indexOf(country.code);
            } else {
              return country.name;
            }
          }
          return "";
        };
      }
    };
  }
]);
