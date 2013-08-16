module.exports = (mongoose) ->

  modelName = 'Counters'

  schema =
    name: 'String'
    number: 'Number'

  counter = mongoose.model modelName, schema

  getNext: (name, systemId, callback) ->
    counter.findOneAndUpdate {name: name, systemId: systemId}
    , {$inc : {number: 1}}, {upsert: true}, (err, res) ->
      if err
        callback('error', null) if callback
      else
        callback(null, res.number) if callback