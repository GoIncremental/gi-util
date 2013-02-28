module.exports =
 
  getNext: (mongoose, name, callback) ->
    counter = mongoose.model 'Counters'
    counter.findOneAndUpdate {name: name}
    , {$inc : {number: 1}}, {upsert: true}, (err, res) ->
      if err
        callback('error', null) if callback
      callback(null, res.number) if callback

  loadSchema: (mongoose) ->
    Schema = mongoose.Schema
    ObjectId = Schema.Types.ObjectId
    name = 'Counters'
    counterSchema = new Schema {name: 'String', number: 'Number' }
    mongoose.model name, counterSchema
