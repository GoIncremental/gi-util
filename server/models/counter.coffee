module.exports = (mongoose) ->
  name = 'Counters'

  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  counterSchema = new Schema {name: 'String', number: 'Number' }

  mongoose.model name, counterSchema
  counter = mongoose.model name
  
  getNext = (name, callback) ->
    counter.findOneAndUpdate {name: name}
    , {$inc : {number: 1}}, {upsert: true}, (err, res) ->
      if err
        callback('error', null) if callback
      callback(null, res.number) if callback

  getNext: getNext
