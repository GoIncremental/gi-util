module.exports = (mongoose) ->
  crud: require('./crud')
  counter: require('./counter')(mongoose)