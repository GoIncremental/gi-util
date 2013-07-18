module.exports = (mongoose) ->

  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  modelName = 'Counters'

  schema =
    name: 'String'
    number: 'Number'

  counterSchema = new Schema schema

  counter = mongoose.model modelName, counterSchema

  getNext: (name, callback) ->
    counter.findOneAndUpdate {name: name}
    , {$inc : {number: 1}}, {upsert: true}, (err, res) ->
      if err
        callback('error', null) if callback
      callback(null, res.number) if callback