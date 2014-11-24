moment = require 'moment'
processSplit = (split) ->
  result = null
  if split.indexOf('|') isnt -1
    splits2 = split.split '|'
    switch splits2[0]
      when "lt"
        result =
          $lt: splits2[1]
      when "ltdate"
        date = moment(splits2[1]
        , ["YYYY-MM-DD", "YYYY-MM-DDTHH:mm:ss"])
        result =
          $lt: date
      when "lte"
        result =
          $lte: splits2[1]
      when "gt"
        result =
          $gt: splits2[1]
      when "gtdate"
        date = moment(splits2[1]
        , ["YYYY-MM-DD", "YYYY-MM-DDTHH:mm:ss"])
        result =
          $gt: date
      when "gte"
        result =
          $gte: splits2[1]
      when "exists"
        result =
          $exists: splits2[1] is "true"
      when "startswith"
        result =
          $regex: new RegExp("^" + splits2[1], "i")
  else
    result = split

    switch split
      when "isnull"
        result =
          $type: 10

  result

processSplits = (splits, k) ->
  results = []

  splits.forEach (split) =>
    obj = {}
    obj[k] = @processSplit split
    results.push obj

  results

module.exports =
  processSplit: processSplit
  processSplits: processSplits
