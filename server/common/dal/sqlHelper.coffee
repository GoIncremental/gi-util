_ = require 'underscore'

generateWhereClause = (query) ->
  clause = ""
  _.each query, (value, key) ->
    if clause is ""
      clause = " WHERE "
    else
      clause = clause + " AND "

    if value.$gt?
      clause = clause + key + " > '" + value.$gt + "'"
    else if value.$gte?
      clause = clause + key + " >= '" + value.$gte + "'"
    else if value.$lt?
      clause = clause + key + " < '" + value.$lt + "'"
    else if value.$lte?
      clause = clause + key + " <= '" + value.$lte + "'"
    else
      clause = clause + key + " = '" + value + "'"

  clause

module.exports =
  generateWhereClause: generateWhereClause
