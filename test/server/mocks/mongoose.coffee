sinon = require 'sinon'
class Schema
  constructor: (schema) ->
    for key, val of schema
      @[key] = val

  virtual: () ->
    get: () ->
    set: () ->
  methods: {}
  pre: () ->
  set: () ->

module.exports =
  model: sinon.stub().withArgs(sinon.match.string).returnsArg 0
  Schema: Schema