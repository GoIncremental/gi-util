
if (typeof exports === "undefined" || exports === null) {
  if (!this.gi) {
    this.gi = {};
  }
  if (!this.gi.util) {
    this.gi['util'] = {};
  }
  if (!this.gi.util.common) {
    this.gi.util['common'] = {};
  }
}

(function(exports) {
  var calculatePeriodStart, enrichPeriod, moment;
  moment = typeof window !== "undefined" && window !== null ? window.moment : require('moment');
  enrichPeriod = function(pattern, recurrence) {
    var calculatedPeriodLength, i, length, missingSecondsInPattern, onTime, s, secondsInADay, _i, _len;
    length = 0;
    secondsInADay = 60 * 60 * 24;
    if (recurrence === 'weekly') {
      length = secondsInADay * 7;
    }
    onTime = 0;
    calculatedPeriodLength = 0;
    for (i = _i = 0, _len = pattern.length; _i < _len; i = ++_i) {
      s = pattern[i];
      if (i % 2 === 1) {
        onTime += s;
      }
      calculatedPeriodLength += s;
    }
    if (calculatedPeriodLength < length) {
      missingSecondsInPattern = length - calculatedPeriodLength;
      pattern.push(missingSecondsInPattern);
      if (pattern.length % 2 === 0) {
        onTime += missingSecondsInPattern;
      }
    }
    return {
      length: length,
      onTime: onTime
    };
  };
  calculatePeriodStart = function(period, start, pattern, recurrence) {
    period.start = moment(start);
    if (recurrence === 'weekly') {
      period.start = moment(start).startOf('week');
    }
    period.secondsToStart = start.diff(period.start, 'seconds');
    return period;
  };
  exports.timeOnBetween = function(_start, _stop, pattern, recurrence) {
    var index, period, result, secondsFromStartToStop, start, stop;
    start = moment(_start);
    stop = moment(_stop);
    result = 0;
    period = enrichPeriod(pattern, recurrence);
    secondsFromStartToStop = stop.diff(start, 'seconds');
    while (secondsFromStartToStop > period.length) {
      result += period.onTime;
      start.add('seconds', period.length);
      secondsFromStartToStop = stop.diff(start, 'seconds');
    }
    period = calculatePeriodStart(period, start, pattern, recurrence);
    index = 0;
    while (true) {
      if (period.secondsToStart >= pattern[index]) {
        period.secondsToStart -= pattern[index];
        index += 1;
      } else {
        break;
      }
    }
    if (index % 2 === 0) {
      if (secondsFromStartToStop >= pattern[index] - period.secondsToStart) {
        secondsFromStartToStop -= pattern[index] - period.secondsToStart;
        index += 1;
      } else {
        secondsFromStartToStop = 0;
      }
    } else {
      if (secondsFromStartToStop >= pattern[index] - period.secondsToStart) {
        result += pattern[index] - period.secondsToStart;
        secondsFromStartToStop -= pattern[index] - period.secondsToStart;
        index += 1;
      } else {
        result += secondsFromStartToStop;
        secondsFromStartToStop = 0;
      }
    }
    while (secondsFromStartToStop > 0) {
      if (index % 2 === 0) {
        if (secondsFromStartToStop >= pattern[index]) {
          secondsFromStartToStop -= pattern[index];
          index += 1;
        } else {
          secondsFromStartToStop = 0;
        }
      } else {
        if (secondsFromStartToStop >= pattern[index]) {
          result += pattern[index];
          secondsFromStartToStop -= pattern[index];
          index += 1;
        } else {
          result += secondsFromStartToStop;
          secondsFromStartToStop = 0;
        }
      }
    }
    return result;
  };
  return exports.timeAfterXSecondsOnFrom = function(_start, x, pattern, recurrence) {
    var index, onSeconds, period, result, start;
    start = moment(_start);
    result = moment(start);
    period = enrichPeriod(pattern, recurrence);
    while (x > period.onTime) {
      result.add('seconds', period.length);
      start.add('seconds', period.length);
      x -= period.onTime;
    }
    period = calculatePeriodStart(period, start, pattern, recurrence);
    index = 0;
    while (true) {
      if (period.secondsToStart >= pattern[index]) {
        period.secondsToStart -= pattern[index];
        index += 1;
        if (index === pattern.length) {
          index = 0;
        }
      } else {
        if (index % 2 === 1) {
          x += period.secondsToStart;
        }
        result.subtract('seconds', period.secondsToStart);
        break;
      }
    }
    while (x > 0) {
      if (index % 2 === 0) {
        result.add('seconds', pattern[index]);
        index += 1;
        if (index === pattern.length) {
          index = 0;
        }
      } else {
        onSeconds = pattern[index];
        if (x >= onSeconds) {
          result.add('seconds', onSeconds);
          x -= onSeconds;
          index += 1;
          if (index === pattern.length) {
            index = 0;
          }
        } else {
          result.add('seconds', x);
          x = 0;
        }
      }
    }
    return result;
  };
})((typeof exports !== "undefined" && exports !== null ? exports : this.gi.util.common['timePatterns'] = {}));

angular.module('gi.util', ['ngResource']);

angular.module('gi.util').factory('giCrud', [
  '$resource', '$q', 'giSocket', function($resource, $q, Socket) {
    var factory;
    factory = function(resourceName, usePromises) {
      var all, allCached, allPromise, count, destroy, destroyPromise, exports, get, getCached, getPromise, items, itemsById, methods, resource, save, savePromise, updateMasterList, version, _version;
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
      resource = $resource('/api/' + resourceName + '/:id', {}, methods);
      items = [];
      itemsById = {};
      updateMasterList = function(newItem) {
        var replaced;
        replaced = false;
        angular.forEach(items, function(item, index) {
          if (!replaced) {
            if (newItem._id === item._id) {
              replaced = true;
              return items[index] = newItem;
            }
          }
        });
        if (!replaced) {
          items.push(newItem);
        }
        itemsById[newItem._id] = newItem;
      };
      all = function(params, callback) {
        var cacheable, options;
        options = {};
        cacheable = true;
        if (_.isFunction(params)) {
          callback = params;
          if (items.length > 0) {
            if (callback) {
              callback(items);
            }
            return;
          }
        } else {
          cacheable = false;
          options = params;
        }
        return resource.query(options, function(results) {
          if (cacheable) {
            items = results;
            angular.forEach(results, function(item, index) {
              itemsById[item._id] = item;
            });
          }
          if (callback) {
            return callback(results);
          }
        });
      };
      allPromise = function(params) {
        var deferred;
        deferred = $q.defer();
        if (params) {
          all(params, function(results) {
            return deferred.resolve(results);
          });
        } else {
          all(function(results) {
            return deferred.resolve(results);
          });
        }
        return deferred.promise;
      };
      save = function(item, success, fail) {
        if (item._id) {
          return resource.save({
            id: item._id
          }, item, function(result) {
            updateMasterList(result);
            if (success) {
              return success(result);
            }
          }, function(failure) {
            if (fail) {
              return fail(failure);
            }
          });
        } else {
          return resource.create({}, item, function(result) {
            updateMasterList(result);
            if (success) {
              return success(result);
            }
          }, function(failure) {
            if (fail) {
              return fail(failure);
            }
          });
        }
      };
      savePromise = function(item) {
        var deferred;
        deferred = $q.defer();
        save(item, function(res) {
          return deferred.resolve(res);
        }, function(err) {
          return deferred.reject(err);
        });
        return deferred.promise;
      };
      getCached = function(id) {
        return itemsById[id];
      };
      allCached = function() {
        return items;
      };
      get = function(id, callback) {
        return resource.get({
          id: id
        }, function(item) {
          if (items.length > 0) {
            updateMasterList(item);
          }
          if (callback) {
            return callback(item);
          }
        });
      };
      getPromise = function(id) {
        var deferred;
        deferred = $q.defer();
        get(id, function(item) {
          return deferred.resolve(item);
        });
        return deferred.promise;
      };
      destroy = function(id, callback) {
        return resource["delete"]({
          id: id
        }, function() {
          var removed;
          removed = false;
          delete itemsById[id];
          angular.forEach(items, function(item, index) {
            if (!removed) {
              if (item._id === id) {
                removed = true;
                return items.splice(index, 1);
              }
            }
          });
          if (callback) {
            return callback();
          }
        });
      };
      destroyPromise = function(id) {
        var deferred;
        deferred = $q.defer();
        destroy(id, function() {
          return deferred.resolve();
        });
        return deferred.promise;
      };
      count = function() {
        return items.length;
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
        get: get,
        getCached: getCached,
        allCached: allCached,
        destroy: destroy,
        save: save,
        count: count,
        version: version
      };
      if (usePromises) {
        exports.all = allPromise;
        exports.query = allPromise;
        exports.get = getPromise;
        exports.save = savePromise;
        exports.destroy = destroyPromise;
      }
      return exports;
    };
    return {
      factory: factory
    };
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

;