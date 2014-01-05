_ = require 'underscore'

generateWhereClause = (query) ->
  clause = ""
  _.each query, (value, key) ->
    if clause is ""
      clause = " WHERE "
    else
      clause = clause + " AND "
    clause = clause + key + " = '" + value + "'"
  clause

module.exports =
  generateWhereClause: generateWhereClause