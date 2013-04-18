_ = require 'underscore'

module.exports =
  
  getNext: (mongoose, name, callback) ->
    counter = mongoose.model 'Counters'
    counter.findOneAndUpdate {name: name}
    , {$inc : {number: 1}}, {upsert: true}, (err, res) ->
      if err
        callback('error', null) if callback
      callback(null, res.number) if callback

  loadSchema: (mongoose) ->
    name = 'Counters'
    if not _.contains(mongoose.modelNames(), name)
      Schema = mongoose.Schema
      ObjectId = Schema.Types.ObjectId
      counterSchema = new Schema {name: 'String', number: 'Number' }
      mongoose.model name, counterSchema
